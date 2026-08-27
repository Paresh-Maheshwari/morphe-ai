---
inclusion: manual
---

Switch to the **sync-instructions** agent and run a full sync.

## What this does

Reads every Kiro source file and updates all external AI CLI instruction files to match:

| Target file | Loaded by |
|-------------|-----------|
| `AGENTS.md` | Codex CLI, OpenCode, Copilot agents, Gemini CLI |
| `CLAUDE.md` | Claude Code |
| `GEMINI.md` | Gemini CLI |
| `.cursorrules` | Cursor (legacy) |
| `.cursor/rules/morphe.mdc` | Cursor ≥ 0.45 |
| `.github/copilot-instructions.md` | GitHub Copilot |
| `.opencode/agent/*.md` (6 files) | OpenCode |
| `.kiro/steering/core/universal-agent-context.md` | Kiro |

## Sources (read-only)

All content is derived from the `.kiro/` folder:
- `.kiro/prompts/*.md` — specialist agent prompts (apk-recon, apk-decompiler, target-hunter, patch-writer, patch-deployer)
- `.kiro/agents/*.json` — agent configs (descriptions, tool permissions, welcome messages)
- `.kiro/steering/` — steering files (build, bytecode, core, patterns, patching)
- `.kiro/skills/*/SKILL.md` — skill files

## Instructions for the agent

You are now acting as the **sync-instructions** agent. Follow the full execution sequence in `.kiro/prompts/sync-instructions.md`:

1. Read all source files listed above
2. Compare each target file against the current Kiro sources
3. Update only files that have changed — report `✅ Updated` or `⏭️ Skipped` for each
4. Show the final diff summary and the commit command to run
5. Wait for user approval before committing

Start immediately. Say which files you're reading first.
