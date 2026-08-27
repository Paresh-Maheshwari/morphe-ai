# Morphe — Claude Code Instructions

> Full project context, pipeline rules, and all specialist agent prompts live in **AGENTS.md**.
> Read that file first. This file adds Claude Code-specific configuration on top.

---

## Quick Start

1. Read `AGENTS.md` — it has the full orchestrator logic, all 6 agent prompts, and every
   code convention you need.
2. You are the **morphe root orchestrator** by default.
3. Always check project state before routing or acting (see AGENTS.md §4).

---

## Claude Code Sub-Agent Setup

When Claude Code supports sub-agents, the specialist agents below are available.
Each has its full prompt in `AGENTS.md §8`. Reference them by name when routing.

| Sub-agent name | Prompt location |
|----------------|----------------|
| apk-recon | AGENTS.md §8a |
| apk-decompiler | AGENTS.md §8b |
| target-hunter | AGENTS.md §8c |
| patch-writer | AGENTS.md §8d |
| patch-deployer | AGENTS.md §8e |

Kiro users: agent configs with full tool permissions are in `.kiro/agents/*.json`.

---

## Allowed Tools & Permissions

When running as root orchestrator:

```
READ:  any file in the workspace
WRITE: paresh-patches/**, analysis/**, .kiro/**
BASH:
  Allowed:  jadx, baksmali, smali, aapt, apktool, rg, find, mkdir, cp, mv,
            unzip, strings, file, diff, git status/log/branch/diff/show/pull,
            ./gradlew, java, adb, uvx, base64, chmod, tar, zip,
            .kiro/jadx-decompile
  Denied:   rm -rf (except /tmp/*), git push, git commit, git reset
```

---

## Project-Specific Bash Snippets

These are the most commonly needed commands:

```bash
# Check app pipeline state
ls analysis/<app>/notes/recon.md analysis/<app>/decompiled/ analysis/<app>/smali/ \
   paresh-patches/patches/src/main/kotlin/app/paresh/patches/<app>/ 2>/dev/null

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
```

---

## Git Safety

- **NEVER** commit or push without explicit user approval
- All work on `dev` branch
- Merge to `main` only after user verifies the build

---

## Context Files (auto-loaded by Kiro)

If you need deeper context on specific topics, these files exist:

| Topic | File |
|-------|------|
| Build system + CLI usage | `.kiro/steering/build/build-and-cli.md` |
| Fingerprinting + smali | `.kiro/steering/bytecode/fingerprinting.md` |
| Smali cheat sheet | `.kiro/steering/bytecode/smali-cheat-sheet.md` |
| Patch development guide | `.kiro/steering/patching/morphe-patch-development-guide.md` |
| Billing bypass patterns | `.kiro/steering/patterns/billing-bypass-patterns.md` |
| Protection bypass patterns | `.kiro/steering/patterns/protection-bypass-patterns.md` |
| Ad blocking patterns | `.kiro/steering/patterns/universal-ad-blocking.md` |
| Community patch analysis | `.kiro/steering/community/` |
| Patch anatomy | `.kiro/skills/patch-anatomy/SKILL.md` |
| Patch examples | `.kiro/skills/patch-examples/SKILL.md` |
| Dev setup | `.kiro/skills/dev-setup/SKILL.md` |
| Patcher APIs | `.kiro/skills/patcher-apis/SKILL.md` |
