# Stake Engine Skills for Claude Code

> Take a developer from a blank folder to a working slot game on [Stake Engine](https://engine.stake.com/) — Claude does the cloning, the version pinning, the smoke test, and answers every question along the way.

Two [Claude Code skills](https://docs.claude.com/en/docs/claude-code/skills) bundling the official Stake Engine Math SDK and Web SDK workflows. Drop them in, ask Claude *"I want to start a Stake Engine slot game"*, watch a sample run.

## What's inside

| Skill | Bootstraps | Then helps with |
|---|---|---|
| **`stake-math-sdk`** | Clones [`StakeEngine/math-sdk`](https://github.com/StakeEngine/math-sdk), Python 3.12+ venv, runs a sample | `GameState`, bet modes, calculations (lines, ways, cluster, scatter, tumble, board), the optimizer, books + lookup-tables, math approval (RTP 90-98%, ±0.5% between modes) |
| **`stake-web-sdk`** | Clones [`StakeEngine/web-sdk`](https://github.com/StakeEngine/web-sdk), Node 22.16 via nvm, pnpm 10.5, smokes Storybook | Monorepo navigation, book events, Pixi components, XState context, RGS HTTP API, frontend approval (static-only, CDN-only, mini-player, mobile, autoplay rules) |

Both skills point at upstream Stake Engine repos as the **source of truth** — the official docs at <https://stakeengine.github.io/math-sdk/> and the repos in <https://github.com/stakeengine>. They stay in sync via `scripts/update-sdk.sh`.

## Install

```bash
# Download the latest release tarball, then:
tar -xzf stake-engine-skills-v0.1.0.tar.gz
cd stake-engine-skills
./install.sh
```

That copies both skills into `~/.claude/skills/`. Restart Claude Code (or open a new session) to load them.

Or clone the repo directly:

```bash
git clone https://github.com/ReSkin-Games/stake-engine-skills.git
cd stake-engine-skills
./install.sh
```

## Use

Open Claude Code in any folder and say:

> *"I want to start a Stake Engine slot game."*

The math skill activates, runs `detect-state.sh`, finds no SDK present, and walks through the bootstrap. After it finishes there's a working `math-sdk` clone next to you, the venv is set up, and a sample game has produced its `books_*.jsonl` and `lookUpTable_*.csv`.

When switching to frontend:

> *"Now let's set up the Web SDK and start playing the sample in Storybook."*

The web skill activates, clones `web-sdk`, installs Node 22.16 via nvm, runs `pnpm install`, and tells you to run `pnpm run storybook --filter=lines`.

After that — ask the skill anything about the docs, the architecture, the approval checklist, how to add an event, how the optimizer works. The skills carry distilled references for every page of the official docs.

## How it works

Each skill follows the [Agent Skills](https://agentskills.io) open standard:

```
stake-math-sdk/
├── SKILL.md              # frontmatter + glossary + navigation, ≤500 lines
├── references/           # 27 on-demand reference files (the docs, distilled)
│   ├── bootstrap.md      # the walkthrough
│   ├── gamestate.md      # GameState, MRO, run_spin
│   ├── optimizer.md      # RTP targeting
│   ├── approval-math.md  # what gets enforced on approval
│   ├── rgs-api.md        # full HTTP contract
│   └── ...
└── scripts/              # atomic shell scripts, each does one thing
    ├── detect-state.sh   # routes to the next needed step
    ├── clone-sdk.sh      # idempotent clone-or-update
    ├── install-python-env.sh
    ├── smoke-test.sh     # runs sample, verifies books output
    └── update-sdk.sh
```

`stake-web-sdk/` follows the same shape with 21 references and 5 scripts pinned to Node 22.16 + pnpm 10.5.

The `SKILL.md` is loaded into Claude's context when the skill activates; references are read on-demand by topic; scripts are executed (their output enters context, not their source). This is [progressive disclosure](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices) — the user gets the right material at the right depth.

## Requirements

| | Math SDK skill | Web SDK skill |
|---|---|---|
| OS | macOS or Linux (Windows: use WSL) | macOS or Linux (Windows: use WSL) |
| Git | required | required |
| Other | Python 3.12+, make, optionally Rust/Cargo for the bundled optimizer | Node 22.x, pnpm 10.x (install steps included in bootstrap) |

The bootstrap scripts check prerequisites and tell you what to install if anything is missing.

## Updating

To pull fresh SDK code:

```bash
~/.claude/skills/stake-math-sdk/scripts/update-sdk.sh <path-to-math-sdk>
~/.claude/skills/stake-web-sdk/scripts/update-sdk.sh <path-to-web-sdk>
```

To get a newer skill bundle: re-extract the new tarball or `git pull` and run `./install.sh` again.

## Building a release

For maintainers:

```bash
# Bump VERSION + update CHANGELOG.md, then:
./pack.sh
# Produces ../stake-engine-skills-v<VERSION>.tar.gz
```

## Source of truth

All references in these skills were distilled from:

- [`StakeEngine/docs`](https://github.com/StakeEngine/docs) — the open-source docs site (cloned at build time)
- The upstream README files of [`StakeEngine/math-sdk`](https://github.com/StakeEngine/math-sdk) and [`StakeEngine/web-sdk`](https://github.com/StakeEngine/web-sdk)
- Stake's published [Approval Guidelines](https://stakeengine.github.io/math-sdk/docs/approval)

If you spot a divergence between the skill and current Stake docs, please [open an issue](https://github.com/ReSkin-Games/stake-engine-skills/issues). Versions and changes are tracked in [`CHANGELOG.md`](CHANGELOG.md).

## License

MIT — see [`LICENSE`](LICENSE).

The Stake Engine SDKs themselves are governed by their own upstream licenses.

## Acknowledgements

Built by [ReSkin Games](https://github.com/ReSkin-Games). The Stake Engine SDKs are by [Stake](https://stake.com/) and their authors — full credit and thanks for keeping the platform open.

Skills authored with [Claude Code](https://claude.com/claude-code), following [Anthropic's skill best-practices](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices).
