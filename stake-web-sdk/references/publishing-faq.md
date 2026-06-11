# Publishing FAQ

Common questions about game publishing, ranking, exclusivity, and post-release handling on Stake Engine.

## Table of Contents

- [Exclusivity and Originality](#exclusivity-and-originality)
- [Content Restrictions](#content-restrictions)
- [Post-Release Restrictions](#post-release-restrictions)
- [Platform Publication](#platform-publication)
- [Quality Ranking](#quality-ranking)
- [Lobby Ranking After Release](#lobby-ranking-after-release)
- [Game Removal After Release](#game-removal-after-release)

## Exclusivity and Originality

- Games must be **original designs**. Pre-purchased or licensed games that exist on other third-party websites are not permitted.
- Team names, game titles, and assets must comply with intellectual property and copyright law. Infringement is grounds for rejection.
- Game assets cannot include Stake / Kick branding or themes.

## Content Restrictions

- Games deemed offensive, explicit, or in poor taste may be rejected at the reviewer's discretion.
- Games that promote, encourage, or are likely to appeal to underage persons are not permitted, including artistic depictions of children or child-like characters in any gambling context.

## Post-Release Restrictions

Once a game is approved and live:

- Only **minor visual updates** to address cosmetic issues are permitted.
- Changes to the **math model** are not allowed.
- Adding **new betmodes** is not allowed.
- Modifications to **gameplay mechanics** are not allowed.

These restrictions apply unless the Stake Engine team specifically requests changes. The game must be finalized before submission.

## Platform Publication

Games are automatically considered for publication on both **stake.com** and **stake.us**, provided they meet the language requirements. Stake Engine provides a social-mode setting in the play modal to test social-casino language replacements. See `reference-locales.md` for the social-mode restricted-phrase list.

## Quality Ranking

Each submission is reviewed by **three anonymous reviewers**. Each picks one fractional score from a fixed scale:

> 0 · 0.33 · 0.67 · 1 · 1.33 · 1.67 · 2 · 2.33 · 2.67 · 3

The final rating is the **rounded average**. If the average is below 1.0, the game receives 0 stars and is **not approved** (an average of 0.67 does not round up to 1).

| Tier | Description | Visibility |
|------|-------------|------------|
| 3 stars | Studio-quality, exceptional creativity, uniqueness, and polish. | Optimal positioning. Eligible for Burst Games, Stake Exclusives, featured New Releases. |
| 2 stars | Considerable creativity or originality; strong development quality. | May appear in Burst Games / Stake Exclusives if popularity drives demand. Placement in New Releases space-dependent. |
| 1 star | Lower polish but meets publishing requirements. | Published with limited visibility. Always at the bottom of New Releases. Not in promotional categories unless exceptional user demand. |
| Below 1 star | Not approved. | Not published. Thread closed and locked for 7 days, then resubmission allowed. |

This policy is in effect as of March 2026 per the source docs.

## Lobby Ranking After Release

When a game is approved and goes live, it is placed at the **bottom of New Releases**. It stays there until the next ranking cycle.

**Re-ranking happens every Friday (Australian time).** All games on the platform are re-ranked weekly based on performance and other ranking criteria.

- Game released Monday → sits at bottom of New Releases until Friday.
- Game released Thursday → re-ranked the next day.
- First ranking update is always the next Friday after release.

Categories (New Releases, Burst Games, Stake Exclusives) are updated weekly.

## Game Removal After Release

Stake Engine reserves the right to disable any published game if issues are discovered after release. Common reasons:

- **Bugs or errors** — gameplay-breaking issues, crashes, unexpected behavior.
- **Math or payout discrepancies** — irregularities vs. the approved spec.
- **Performance issues** — excessive load times, memory leaks, rendering failures.
- **Compliance concerns** — content/behavior no longer meeting platform or regulatory requirements.

When a game is disabled:

1. The game is **removed from the lobby**.
2. The **approval thread is reopened** so the Stake Engine team can communicate the issue.
3. The publisher must **identify and fix** the problem.
4. The updated build is submitted for **re-review through the same thread** (do not create a new submission).
