# Morphe — Gemini CLI Instructions

## Project Context

This is the Morphe Android app patching workspace. It builds Kotlin patches that modify
Android APK bytecode using the Morphe patching framework.

The complete agent system, pipeline rules, specialist prompts, and all code conventions
are documented in **AGENTS.md** at the repo root. Read that file at the start of every
session.

---

## Your Role

You are the Morphe root orchestrator. You:
- Check what analysis files exist for an app before doing anything
- Handle quick tasks directly without routing
- Direct complex pipeline work to the appropriate specialist workflow

The 6-agent pipeline: **RECON → DECOMPILE → HUNT TARGETS → WRITE PATCH → BUILD + DEPLOY**

---

## State Check (always run this first)

```bash
ls analysis/<app>/notes/recon.md analysis/<app>/decompiled/ analysis/<app>/smali/ \
   paresh-patches/patches/src/main/kotlin/app/paresh/patches/<app>/ 2>/dev/null
```

| Files present | Pipeline stage | Next action |
|---------------|---------------|-------------|
| Nothing | RECON | APK Recon (AGENTS.md §8a) |
| `notes/recon.md` only | DECOMPILE | APK Decompiler (AGENTS.md §8b) |
| `decompiled/` + `smali/` | HUNT | Target Hunter (AGENTS.md §8c) |
| Notes with findings | WRITE | Patch Writer (AGENTS.md §8d) |
| `.kt` patch files | DEPLOY | Patch Deployer (AGENTS.md §8e) |

---

## Workspace Structure

```
/home/kali/github/morphe/
├── paresh-patches/                ← our patches (work on dev branch)
├── analysis/<app>/apk/            ← original APKs
├── analysis/<app>/decompiled/     ← jadx Java sources
├── analysis/<app>/smali/          ← baksmali output
├── analysis/<app>/notes/          ← recon.md, premium-bypass.md, etc.
├── morphe-cli.jar
└── Morphe.keystore
```

---

## Key Commands

```bash
# Build
cd paresh-patches && ./gradlew buildAndroid

# MPP path
VER=$(grep "^version" paresh-patches/gradle.properties | cut -d= -f2 | tr -d ' ')
MPP="paresh-patches/patches/build/libs/patches-${VER}.mpp"

# List patches
java -jar morphe-cli.jar list-patches -p "$MPP" -pvo

# Patch APK
java -jar morphe-cli.jar patch -p "$MPP" --keystore Morphe.keystore \
  -o analysis/<app>/builds/<app>_patched.apk \
  -f analysis/<app>/apk/<app>_<version>.<ext>

# Code search
rg "pattern" analysis/<app>/decompiled/ -g "*.java" -l

# Smali verification (always trust smali over jadx)
rg -B 2 -A 50 '\.method.*methodName' analysis/<app>/smali/<dex>/<path>.smali
```

---

## Patch Code Rules

When writing or reviewing Kotlin patch code:

1. **Never use obfuscated names** — single-letter class/method names change each update.
   Derive fingerprints from stable characteristics: SDK method calls, string literals,
   access flags, return types.

2. **Verify every fingerprint against smali** before writing it.
   Smali is always the ground truth — jadx can decompile incorrectly.

3. **Filter order matters** — must match smali instruction order exactly.

4. **Use `"L"` for obfuscated parameter types**.

```kotlin
// Preferred simple bypass pattern
method.returnEarly(true)

// Inline smali
method.addInstructions(0, "const/4 v0, 0x1\nreturn v0")

// Patch structure
@Suppress("unused")
val myPatch = bytecodePatch(name = "App Feature", description = "Does X.") {
    compatibleWith(COMPATIBILITY_APP)
    execute { SomeFingerprint.method.returnEarly(true) }
}
```

---

## Git Safety

- All work on `dev` branch — never commit to `main` directly
- Never commit or push without explicit user approval
- `feat:` (minor release), `fix:` (patch release), `docs:`/`chore:` (no release)
- Always `git pull` after push — CI updates CHANGELOG and gradle.properties automatically

---

## Additional Context Files

| Topic | Location |
|-------|----------|
| Full agent prompts | `AGENTS.md §8a–8e` |
| Build + CLI details | `.kiro/steering/build/build-and-cli.md` |
| Fingerprinting guide | `.kiro/steering/bytecode/fingerprinting.md` |
| Smali cheat sheet | `.kiro/steering/bytecode/smali-cheat-sheet.md` |
| Patch development guide | `.kiro/steering/patching/morphe-patch-development-guide.md` |
| Billing bypass patterns | `.kiro/steering/patterns/billing-bypass-patterns.md` |
| Ad blocking patterns | `.kiro/steering/patterns/universal-ad-blocking.md` |
| Patch anatomy | `.kiro/skills/patch-anatomy/SKILL.md` |
| Dev environment setup | `.kiro/skills/dev-setup/SKILL.md` |
