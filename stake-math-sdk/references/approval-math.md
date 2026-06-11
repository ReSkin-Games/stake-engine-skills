# Approval — Math Requirements

Math-side approval criteria for games submitted to Stake Engine. Distilled from the official approval guidelines.

## Table of Contents

- [Stateless Requirement](#stateless-requirement)
- [RTP and Mode Cost](#rtp-and-mode-cost)
- [Maximum Win](#maximum-win)
- [Simulation Volume](#simulation-volume)
- [Hit-Rate Rules](#hit-rate-rules)
- [Volatility and Standard Deviation](#volatility-and-standard-deviation)
- [Payout Distribution](#payout-distribution)
- [Restricted Features](#restricted-features)
- [Post-Approval Restrictions](#post-approval-restrictions)
- [Quality Ranking Impact](#quality-ranking-impact)

## Stateless Requirement

Games must be strictly stateless. Each bet is independent of previous outcomes. The math model cannot reference, persist, or be influenced by prior rounds, player actions, or external factors. The RGS does not store round history; outcomes derive solely from weighted random selection over the LUT.

## RTP and Mode Cost

- Calculated RTP must fall within **90.0% to 98.0%** for every betmode.
- For games with multiple betmodes, all betmode RTPs must fall within a **0.5% variation** of each other.
  - Example: a BASE mode at 97.0% RTP requires every other betmode to be between 96.5% and 97.5%.
- The cost of each betmode must be correctly represented in the in-game rules.

## Maximum Win

- The maximum win amount must match the value declared in the game rules for every betmode.
- The maximum win must be realistically obtainable. As a rough guide: **frequency more often than 1 in 10,000,000**, with tolerance depending on payout magnitude.

## Simulation Volume

- For slot-type games, **100,000 to 1,000,000 simulations** per betmode are required to ensure sufficient outcome diversity and prevent repeated results within a session.

## Hit-Rate Rules

- Hit-rate of non-zero wins should align with industry standards: **more frequent than 1 in 20 bets**.
- A reasonable portion of simulations must yield paying results. Example threshold: 90,000 non-paying results out of 100,000 simulations is grounds for rejection.
- The hit-rate of the single most likely simulation must not dominate the distribution when the game visually implies varied results.
- Win-range hit-rates must avoid gaps where expected intermediate win amounts are unobtainable. Intermediate wins must exist between small payouts and the maximum payout.

## Volatility and Standard Deviation

- For BASE modes (cost multiplier 1x), standard deviation must be within industry norms for the slot category to provide reasonable volatility.

## Payout Distribution

- List the number of non-zero-weight payouts in the model.
- Zero-weight payouts must not dominate the simulation set.
- Verify all symbol combinations declared in rules are reachable in the simulation set.

## Restricted Features

The following are not permitted in the math model:

- Jackpots
- Gamble features
- Round continuation between sessions beyond the standard active-round resume
- Early cashout / cash-out options

## Post-Approval Restrictions

Once a game is approved:

- Changes to the underlying math model are **not allowed**.
- Adding **new betmodes** is **not allowed**.
- Modifications to gameplay mechanics are **not allowed**.
- Only minor visual updates to address cosmetic issues are permitted.

Math must be finalized before submission.

## Quality Ranking Impact

Math quality contributes to the overall game rating (0-3 stars) assigned by three anonymous reviewers. Games rated below 1 star are not published. Math-relevant signals reviewers consider:

- Variety of outcomes in the simulation set
- Correctness of rules vs. behavior (verified by replay events)
- Absence of misleading visual expectations vs. true probability

For data file format (LUT and Book structure) referenced during math validation, see `how-rgs-works.md`.
