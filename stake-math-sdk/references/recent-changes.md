# Stake Engine — Recent Changes

Distilled from `src/routes/changelog/` on stake-engine.com. Ordered newest first.

## 2026-03-17 — Rating System Minimum Threshold (breaking)

Games with an average rating below **1 star** are no longer approved for publication.

- The approval thread is closed and locked on rejection.
- The thread stays locked for **7 days**, giving the creator time to improve the game.
- After 7 days the game can be resubmitted for review.

Rationale: low-rated games consume disproportionate review time and hurt the player experience. See `/docs/approval/quality` for the full star-tier rules.

## 2026-03-01 — February 2026 Publisher Payments

- **>$6M USD** paid out.
- **211 active providers**, **738 live games**.
- **>560M bets** accepted by the RGS in 4 weeks.
- **>470,000 unique users** on Stake Engine.
- Biggest single bet (non-affiliate): **$395K USD**.
- Largest single payout (non-affiliate): **$7.5M USD**.

## 2026-02-01 — January 2026 Publisher Payments

- **~$5M USD** paid out.
- **170+ active publishers**, **580+ games**.
- **>650M bets** placed on the RGS in January.
- Profit to non-internal teams more than doubled month-over-month.

## 2026-01-01 — December 2025 Publisher Payments

- **>$4.2M USD** publisher profit.
- **116 teams**, **458 active games**.

## 2025-12-01 — November 2025 Publisher Payments

- **$2.8M USD** paid out.
- **116 teams**, **357 live games**.

## 2025-11-09 — Replay Mode (feature)

Bet Replay is now a **mandatory requirement** for all games. Rounds can be shared and replayed via a `?replay=true&game=...&mode=...&event=...&currency=...&amount=...` URL.

Start-Replay button must show:

- Game mode.
- Base bet amount, cost multiplier, currency symbol (when provided).
- Total amount actually spent on the bet (for bonus-buys with a cost multiplier, use the buy amount, not the base bet).
- If currency / amount are missing, default display to **1 USD** (non-social) or **1 SC** (social).
- No need to display the event id.

Full details, query parameters, and the implementation checklist live at `/docs/api/bet-replay`. The approval checklist is being updated to enforce the requirements.
