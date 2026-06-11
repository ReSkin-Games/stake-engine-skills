# Setup

Local environment for the Stake Engine Web SDK.

Upstream repo: https://github.com/StakeEngine/web-sdk

## Required versions

- Node `18.18.0`
- pnpm `10.5.0`

These are the versions pinned by the upstream Getting Started page. Use `nvm` to match Node exactly.

## Install Node via nvm

```sh
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Load nvm without restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Install the pinned Node version
nvm install 18.18.0

# Verify (should print v18.18.0)
node -v
```

## Install pnpm

```sh
npm install pnpm@10.5.0 -g
pnpm -v   # should print 10.5.0
```

## Clone and install

```sh
git clone <REPO_CLONE_URL>
cd web-sdk
pnpm install
```

The repo is a Turborepo monorepo; `pnpm install` resolves all workspaces under `apps/*` and `packages/*`.

## Running a sample game

Turborepo filters by package name (the `name` field in `package.json`).

```sh
# Storybook for the `lines` sample game
pnpm run storybook --filter=lines

# Dev server for the `lines` sample game
pnpm run dev --filter=lines
```

`pnpm dev` launches the SvelteKit dev server for one app and is suitable for running the game like an end user would see it. `pnpm storybook` launches Storybook for the same app and is the primary development surface — stories exist at component, bookEvent, and whole-book level (see `references/storybook.md`).

## VS Code

Recommended IDE per upstream docs. Download: https://code.visualstudio.com/download
