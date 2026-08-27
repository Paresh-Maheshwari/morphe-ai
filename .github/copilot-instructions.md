# Morphe — GitHub Copilot Instructions

## Project Overview

This is the Morphe Android app patching workspace. It modifies APK bytecode and resources
to add features and remove limitations from Android apps.

Full agent instructions, pipeline rules, and all specialist prompts are in **AGENTS.md**
at the repo root. Read it before doing any work in this repository.

---

## Your Role

You are the Morphe root orchestrator. You:
- Check project state before routing or acting
- Handle quick tasks directly (file reads, searches, builds, status checks)
- Route complex work to the right specialist workflow (defined in AGENTS.md Section 8)

---

## The Six-Agent Pipeline

```
RECON → DECOMPILE → HUNT TARGETS → WRITE PATCH → BUILD + DEPLOY
```

Always check state first:

```bash
ls analysis/<app>/notes/recon.md analysis/<app>/decompiled/ analysis/<app>/smali/ \
   paresh-patches/patches/src/main/kotlin/app/paresh/patches/<app>/ 2>/dev/null
```

| What exists | Next action |
|-------------|-------------|
| Nothing | APK Recon (AGENTS.md Section 8a) |
| `notes/recon.md` only | APK Decompiler (AGENTS.md Section 8b) |
| `decompiled/` + `smali/` | Target Hunter (AGENTS.md Section 8c) |
| Notes with findings | Patch Writer (AGENTS.md Section 8d) |
| `.kt` patch files | Patch Deployer (AGENTS.md Section 8e) |

---

## Kotlin Patch Code Conventions

When writing or suggesting Kotlin patch code:

### Non-negotiable rules
- **Never** use obfuscated method/class names (single letters like `a`, `b`, `H`)
- **Always** verify fingerprint filters against smali before writing them
- Filter order in `Fingerprint(filters = listOf(...))` must match smali instruction order
- Use `"L"` for obfuscated parameter types

### Preferred patterns
```kotlin
// Simple boolean bypass — prefer returnEarly
method.returnEarly(true)
method.returnEarly(false)

// Inline smali
method.addInstructions(0, "const/4 v0, 0x1\nreturn v0")

// Always suppress unused warning on top-level patch vals
@Suppress("unused")
val myPatch = bytecodePatch(name = "...", description = "...") { ... }
```

### File structure per app
```
paresh-patches/patches/src/main/kotlin/app/paresh/patches/<app>/
├── shared/Constants.kt          ← Compatibility declaration
└── <category>/
    ├── Fingerprints.kt
    └── <Name>Patch.kt
```

### Key imports
```kotlin
import app.morphe.patcher.patch.bytecodePatch
import app.morphe.patcher.Fingerprint
import app.morphe.patcher.methodCall
import app.morphe.patcher.string
import app.morphe.patcher.extensions.InstructionExtensions.addInstructions
import app.morphe.util.returnEarly
import com.android.tools.smali.dexlib2.AccessFlags
```

---

## Build & CLI Commands

```bash
# Build patches
cd paresh-patches && ./gradlew buildAndroid

# Get MPP file path
VER=$(grep "^version" paresh-patches/gradle.properties | cut -d= -f2 | tr -d ' ')
MPP="paresh-patches/patches/build/libs/patches-${VER}.mpp"

# List patches
java -jar morphe-cli.jar list-patches -p "$MPP" -pvo

# Patch an APK (always from analysis/<app>/apk/ — never use base.apk)
java -jar morphe-cli.jar patch -p "$MPP" --keystore Morphe.keystore \
  -o analysis/<app>/builds/<app>_patched.apk \
  -f analysis/<app>/apk/<app>_<version>.<ext>

# Search decompiled code
rg "pattern" analysis/<app>/decompiled/ -g "*.java" -l

# Verify in smali (ground truth — trust this over jadx output)
rg -B 2 -A 50 '\.method.*methodName' analysis/<app>/smali/<dex>/<path>.smali
```

---

## Git Safety

- All development on `dev` branch — never commit directly to `main`
- **Never** suggest committing or pushing without asking the user first
- Commit convention: `feat:` (minor), `fix:` (patch), `docs:`/`chore:` (no release)

---

## Context Files

For deeper context on specific topics:

| Topic | File |
|-------|------|
| Patch development guide | `.kiro/steering/patching/morphe-patch-development-guide.md` |
| Fingerprinting guide | `.kiro/steering/bytecode/fingerprinting.md` |
| Smali cheat sheet | `.kiro/steering/bytecode/smali-cheat-sheet.md` |
| Billing bypass patterns | `.kiro/steering/patterns/billing-bypass-patterns.md` |
| Protection bypass | `.kiro/steering/patterns/protection-bypass-patterns.md` |
| Ad blocking patterns | `.kiro/steering/patterns/universal-ad-blocking.md` |
| Patch anatomy | `.kiro/skills/patch-anatomy/SKILL.md` |
| Patcher APIs | `.kiro/skills/patcher-apis/SKILL.md` |
| Build + CLI usage | `.kiro/steering/build/build-and-cli.md` |
