# Stake Engine — Getting Started FAQ

Distilled from `src/routes/faq/getting-started/` on stake-engine.com.

## How do I start building a game?

Five-step path from zero to a live game:

1. **Register** — create an account at `stake-engine.com` and set up the team profile.
2. **Define game math** — symbol distributions, paylines, win conditions, target RTP, hit frequency. Run simulations to validate the numbers. (Math SDK territory.)
3. **Build the frontend** — visual presentation, talks to the RGS to authenticate sessions, place bets, render results. (Web SDK territory.)
4. **Test with the RGS** — integrate against the three core endpoints: `/docs/api/authenticate`, `/docs/api/play`, `/docs/api/end-round`. Exercise the full round lifecycle.
5. **Submit for approval** — upload the build through the dashboard, then walk the `/docs/approval` checklist.

## Stack requirements

Any tech stack is allowed, but the final build must be **fully static** — HTML / CSS / JS / assets only. No SSR, no backend processes. Builds are served from the Stake Engine CDN.

## Recommended starting points

- **Math:** `Math SDK` at `/docs/math-sdk` — common patterns (lines / ways / cluster / scatter / tumble) out of the box.
- **Frontend:** `Web SDK` at `/docs/web-sdk` — Pixi + Svelte monorepo with reusable RGS / state / UI packages.
