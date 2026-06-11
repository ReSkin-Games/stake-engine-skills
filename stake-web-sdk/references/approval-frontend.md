# Approval — Frontend Requirements

Frontend-side approval criteria for games submitted to Stake Engine. Distilled from the official approval guidelines.

## Table of Contents

- [Build and Asset Delivery](#build-and-asset-delivery)
- [Visual Quality and Compatibility](#visual-quality-and-compatibility)
- [Rules and Paytable](#rules-and-paytable)
- [UI Components](#ui-components)
- [Input and Interaction](#input-and-interaction)
- [Sound](#sound)
- [Autoplay](#autoplay)
- [Network and Logging](#network-and-logging)
- [Localization](#localization)
- [Bet Replay](#bet-replay)
- [Game Tile](#game-tile)
- [Disclaimer](#disclaimer)
- [Quality Ranking](#quality-ranking)
- [Post-Approval Restrictions](#post-approval-restrictions)

## Build and Asset Delivery

- The build must consist of **static files only**. No server-side rendering, no runtime fetches from external origins.
- A strict XSS policy is enforced. External font, script, or asset fetches will log console errors and fail approval.
- All images, fonts, and other assets must be loaded from the Stake Engine CDN.
- Submitted games must use **unique audio and visual assets**. Assets shipped with web-sdk sample games are not permitted in production submissions.

## Visual Quality and Compatibility

- The game must be free of visual bugs (broken/missing assets, missing animations).
- **Mini-player (popout) support**: the game must render correctly inside the mini-player modal without distorting the active game board.
- **Mobile support**: commonly used mobile devices must be supported, with all UI functionality usable during screen scaling.
- For supported viewport sizes (desktop, laptop, popout L/S, mobile L/M/S), see `reference-locales.md`.

## Rules and Paytable

The rules / info popup must be accessible from the UI and must include:

- A detailed description of all game rules.
- For multi-betmode games, the cost of each betmode and the actions purchased.
- The RTP of the game and of each betmode.
- The maximum win amount per betmode.
- Payout amounts for all symbol combinations.
- All obtainable values of any special symbols (cash prizes, multipliers, etc.).
- For feature modes (e.g. scatter-triggered free spins), the trigger conditions and rewards. Example: "3 Scatters award 10 free spins; 4 Scatters award 15 spins".

## UI Components

- A **UI guide** describing the function of each button.
- A **bet size selector**.
- Support for **all bet levels** returned in the authenticate response.
- Bet increments must respect `config.stepBet` from authenticate.
- Minimum and maximum bet levels must be selectable as dictated by the RGS.
- Display of the player's **current balance**.
- Display of the **final win amount** for non-zero payouts.
- For outcomes with multiple winning actions, the displayed payout must increment to match the final payout multiplier.

## Input and Interaction

- The **spacebar must be mapped to the bet button**.
- If a fastplay option exists, win amounts, winning symbol combinations, and popup information must remain legible.

## Sound

- A UI option to **disable sounds (mute)** must be available.

## Autoplay

- If autoplay is present, the player must **confirm the autoplay action** explicitly. Games are not permitted to place consecutive bets automatically from a single click.

## Network and Logging

- The browser network tab must show no errors and no leakage of game/internal information during play.
- Console must be clean during normal play.

## Localization

- **English (`en`) is the only required language.**
- If only English is supported, on-screen text must not corrupt or break when other `lang` query parameter values are passed.
- Games are tested with various currency and language combinations.
- For supported language codes and currency codes, see `reference-locales.md`.
- For social-mode (Stake.us) restricted-phrase replacements, see `reference-locales.md`.

## Bet Replay

Bet replay support is **mandatory** for approval. Required behavior:

- Detect `replay=true` query parameter and switch to replay mode.
- Fetch round data from `GET {rgs_url}/bet/replay/{game}/{version}/{mode}/{event}`.
- No authenticate / balance / play / event API calls in replay mode.
- Disable or hide bet controls and balance display.
- Show a Play button to start the replay, run the full animation, show results, then offer Play Again.
- Handle fetch errors gracefully.

During review, event IDs for the following scenarios must be supplied **per betmode**: normal win, big win, win cap, loss, bonus trigger (if applicable). See `rgs-api.md` for the bet-replay endpoint contract.

## Game Tile

Game tiles are composed in the Stake Engine dashboard **Tile Editor**. Separate tile asset files are not submitted with the build.

**Provider logo** (Team Settings → Branding, applied automatically to all tiles):
- PNG, JPG, or GIF up to 10 MB.
- Square ratio recommended.
- Transparent background and padding recommended for legibility at small sizes.

**Tile composition layers**:

| Layer | Requirements |
|-------|--------------|
| Background | High-res PNG/JPG. Brighter than the Stake platform — dark backgrounds blend in. Avoid dark edges. No text, no multipliers baked in. |
| Foreground element | High-res PNG with transparent background. Character/key item enlarged to fill the key focus area. No text or multipliers. |
| Gradient | Light overlay using a prominent colour already in the artwork. Must enhance text readability without dominating. Avoid bright yellow/green/blue. |
| Game title | Fits within the height of the title guide. Fills the text-box width. Maximum 2 text sizes per tile. |

Tiles with dark edges, low-contrast backgrounds, or text/multipliers baked into imagery are rejected.

## Disclaimer

Every game must include a legal disclaimer in its rules or information popup. The disclaimer must be reachable from the `i` / `?` button at all times during gameplay (not required on every screen).

**Official template** (custom wording is allowed if all required points are covered):

> Malfunction voids all wins and plays. A consistent internet connection is required. In the event of a disconnection, reload the game to finish any uncompleted rounds. The expected return is calculated over many plays. The game display is not representative of any physical device and is for illustrative purposes only. Winnings are settled according to the amount received from the Remote Game Server and not from events within the web browser. TM and (c) 2025 Stake Engine.

**Required points** (must all be covered):

| Point | Description |
|-------|-------------|
| Malfunction clause | Malfunctions void all wins and plays. |
| Internet requirement | A stable connection is required for gameplay. |
| Disconnection recovery | Players can reload the game to finish uncompleted rounds. |
| Expected return | RTP is calculated over many plays, not per session. |
| Display accuracy | The game display is illustrative and not a physical device. |
| Payout source | Winnings are determined by the RGS, not browser events. |
| Copyright | Appropriate trademark and copyright notice. |

Games submitted without a disclaimer in the rules/info popup will not pass approval.

## Quality Ranking

Each game is reviewed by **three anonymous reviewers**, who each select one of the following fractional scores: 0, 0.33, 0.67, 1, 1.33, 1.67, 2, 2.33, 2.67, 3. The final rating is the rounded average.

| Tier | Visibility |
|------|------------|
| 3 stars | Optimal positioning, eligible for Burst Games, Stake Exclusives, featured New Releases. |
| 2 stars | May appear in Burst Games / Stake Exclusives if popularity drives demand. |
| 1 star | Published with limited visibility, always at the bottom of New Releases. |
| Below 1 star (average < 1.0) | **Not approved**. Thread closes for 7 days, then resubmission allowed. |

Frontend polish, creativity, and originality directly influence ranking.

## Post-Approval Restrictions

Once approved, only **minor visual updates** to address cosmetic issues are permitted. Changes to math, new betmodes, and gameplay mechanic changes are not allowed unless requested by Stake Engine.
