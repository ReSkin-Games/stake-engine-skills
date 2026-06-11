# Bootstrap workflow

Walkthrough for setting up `web-sdk` from scratch. Each step calls an atomic script in `scripts/`. Follow in order; skip steps where `detect-state.sh` reports them already complete.

## Contents

- Pre-flight checks
- Step 1: Install Node and pnpm
- Step 2: Choose location
- Step 3: Clone web-sdk
- Step 4: Install dependencies
- Step 5: Smoke test
- Step 6: Run Storybook
- Step 7: Done — what to do next
- Troubleshooting

## Pre-flight checks

Run `scripts/detect-state.sh` first. It returns:

| Exit | Meaning | Next step |
|------|---------|-----------|
| 0 | READY | Skip to "Step 6: Run Storybook" |
| 10 | NEEDS_DEPS | Step 1 (install missing prerequisite) |
| 20 | NEEDS_CLONE | Step 3 |
| 30 | NEEDS_INSTALL | Step 4 |
| 40 | NEEDS_SMOKE | Step 5 |

Prerequisites:
- macOS or Linux (Windows: use WSL).
- `git` installed.

## Step 1: Install Node and pnpm

Upstream `web-sdk` requires **Node 22.16.0** and **pnpm 10.5.0** (pinned in the README).

Install nvm + Node 22.16:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22.16.0
nvm use 22.16.0
node -v  # should print v22.16.0
```

Install pnpm:

```bash
npm install -g pnpm@10.5.0
pnpm -v  # should print 10.5.0
```

## Step 2: Choose location

Ask the user where to put `web-sdk`. Reasonable defaults:

- Inside the current project folder: `./web-sdk`.
- A shared parent: `$HOME/stake-engine/web-sdk`.

Record the chosen path. All later scripts take it as `$1`.

## Step 3: Clone web-sdk

```bash
scripts/clone-sdk.sh <chosen-path>
```

Clones `https://github.com/StakeEngine/web-sdk.git` (shallow). No-op if already cloned.

## Step 4: Install dependencies

```bash
scripts/install-deps.sh <chosen-path>
```

Runs `pnpm install`. Takes 1-3 minutes (Turborepo with many packages).

## Step 5: Smoke test

```bash
scripts/smoke-test.sh <chosen-path>
```

Verifies `pnpm storybook --help` works and `turbo build --dry=json --filter=lines` resolves the dependency graph. Fast (~5 sec).

## Step 6: Run Storybook

```bash
cd <chosen-path>
pnpm run storybook --filter=lines
```

Opens Storybook in the browser. Pick `MODE_BASE/book/random` from the left sidebar, click the `Action` button to play a sample round.

To run a different sample game, replace `lines` with another folder name from `apps/`. See `references/sample-apps.md`.

## Step 7: Done — what to do next

Now `web-sdk` is functional. Common next actions:

- **Pick a sample to base the game on**: `references/sample-apps.md` describes each `apps/*`.
- **Understand the flow**: `references/flow-and-events.md` covers how RGS book events drive rendering.
- **Add a new event**: `references/adding-events.md` walks through end-to-end.
- **Build your own components**: `references/ui-and-components.md` and `references/pixi-svelte.md`.
- **Wire to the live RGS**: `references/rgs-api.md` + `web-sdk/packages/rgs-fetcher/`.

## Troubleshooting

**`node: command not found` after nvm install**
Add to `~/.zshrc` (or `~/.bashrc`):
```
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```
Then `source ~/.zshrc` (or open a new terminal).

**Node version is right in one terminal but wrong in another**
`nvm use 22.16.0` is per-shell. Add `nvm use 22.16.0` to the shell rc, or run it at the start of each session.

**`pnpm install` fails on lockfile mismatch**
```bash
cd <web-sdk-dir>
rm -rf node_modules pnpm-lock.yaml
pnpm install
```

**Storybook starts but page is blank**
- Check the browser console for errors (often a missing asset path).
- Try a different sample app (`--filter=cluster`).
- Verify `pnpm-lock.yaml` is committed and matches `package.json`.

**On Windows: storybook script fails**
Per upstream README, Windows users may need to add `cross-env` to the storybook script:
```json
"storybook": "cross-env PUBLIC_CHROMATIC=true storybook dev -p 6001 public"
```
Or use WSL instead.

**Update existing clone**
```bash
scripts/update-sdk.sh <web-sdk-dir>
pnpm install  # re-run if package.json changed
```
