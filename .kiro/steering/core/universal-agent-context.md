---
inclusion: always
---

# Universal Agent Context

This workspace supports multiple AI CLI tools. The following files contain the full
agent system and are automatically loaded by each tool:

| Tool | File loaded |
|------|------------|
| Kiro | `.kiro/agents/*.json` + `.kiro/steering/` + `.kiro/skills/` |
| Claude Code | `CLAUDE.md` → `AGENTS.md` |
| OpenAI Codex CLI | `AGENTS.md` |
| OpenCode | `AGENTS.md` + `.opencode/agent/*.md` |
| Gemini CLI | `GEMINI.md` → `AGENTS.md` |
| Cursor | `.cursor/rules/morphe.mdc` + `.cursorrules` → `AGENTS.md` |
| GitHub Copilot | `.github/copilot-instructions.md` → `AGENTS.md` |

## Source of Truth

**`AGENTS.md`** at the repo root is the single source of truth for:
- Project overview and workspace layout (Section 1–2)
- Orchestrator decision rules and pipeline routing (Section 3–4)
- All key commands (Section 5)
- Patch code conventions and templates (Section 6)
- Git workflow (Section 7)
- All 5 specialist agent prompts (Section 8a–8e)
- Supported apps (Section 9)
- Dev environment setup (Section 10)

When working in Kiro, `.kiro/` provides richer tool-level configs (allowed commands,
path restrictions, hooks). The semantic content is the same as `AGENTS.md`.
