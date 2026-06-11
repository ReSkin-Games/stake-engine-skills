# Changelog

## 0.1.0 — 2026-06-11

Initial release.

- Two skills: `stake-math-sdk`, `stake-web-sdk`.
- Source-of-truth: `StakeEngine/docs` @ `fefadc7` (2026-03-17), upstream `math-sdk` and `web-sdk` READMEs as of 2026-06-11.
- Versions pinned in bootstrap scripts:
  - Math SDK: Python 3.12+, Rust/Cargo (optional, for bundled optimizer).
  - Web SDK: Node 22.16.0, pnpm 10.5.0.
- Atomic bootstrap scripts (`detect-state`, `clone-sdk`, `install-*`, `smoke-test`, `update-sdk`) per skill.
- Distribution: tarball via `pack.sh`, `install.sh` copies into `~/.claude/skills/`.
