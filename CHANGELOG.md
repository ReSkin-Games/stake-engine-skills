# Changelog

## 0.2.0 — 2026-06-11

- **Stake MCP server integration**: `install.sh` now offers to install Stake's official `stake-engine-docs` MCP server alongside the skills. Once registered (auto-detected via the `claude mcp add` CLI), Claude can query the live docs by `search_docs`, `get_page`, `list_pages`, `get_section_tree`. Both `SKILL.md` files updated to prefer MCP results over distilled references when an exact current quote is needed.
- New scripts: `install-mcp.sh` (idempotent: clones `StakeEngine/docs`, builds the MCP server, registers with Claude Code, prints config snippet for Cursor/Windsurf/Codex) and `uninstall-mcp.sh`.
- **Universal `AGENTS.md`** at the repo root. Compact (~200 lines): glossary, contracts, setup commands, repo layouts, common workflows, anti-patterns. Read by Cursor, Windsurf, Codex CLI, Aider, and other AGENTS-aware tools.
- **README**: new "Supported tools" section with a matrix (Claude Code: full; Cursor/Windsurf/Codex: passive + MCP).
- `SKIP_MCP=1 ./install.sh` to skip the MCP prompt.

## 0.1.0 — 2026-06-11

Initial release.

- Two skills: `stake-math-sdk`, `stake-web-sdk`.
- Source-of-truth: `StakeEngine/docs` @ `fefadc7` (2026-03-17), upstream `math-sdk` and `web-sdk` READMEs as of 2026-06-11.
- Versions pinned in bootstrap scripts:
  - Math SDK: Python 3.12+, Rust/Cargo (optional, for bundled optimizer).
  - Web SDK: Node 22.16.0, pnpm 10.5.0.
- Atomic bootstrap scripts (`detect-state`, `clone-sdk`, `install-*`, `smoke-test`, `update-sdk`) per skill.
- Distribution: tarball via `pack.sh`, `install.sh` copies into `~/.claude/skills/`.
