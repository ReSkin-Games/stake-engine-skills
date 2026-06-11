# Approval — RGS Requirements

RGS-side approval criteria. Session authentication and bet transactions on Stake Engine are handled exclusively through the Stake Engine RGS.

## Table of Contents

- [Session and Authentication](#session-and-authentication)
- [Bet Level Verification](#bet-level-verification)
- [RGS URL Handling](#rgs-url-handling)
- [Currency Enforcement](#currency-enforcement)
- [Language Enforcement](#language-enforcement)
- [XSS Policy](#xss-policy)

## Session and Authentication

- All wallet endpoints require a valid `sessionID` issued by the operator platform and passed via URL.
- The session must be validated via `POST /wallet/authenticate` before any other wallet call. Calling other endpoints first returns `ERR_IS` (Invalid Session).
- The session has a limited lifetime. If it expires, the player must relaunch the game.
- See `rgs-api.md` for endpoint contracts.

## Bet Level Verification

The `/wallet/authenticate` response returns:

- Default bet level
- Supported bet levels for the session currency
- Minimum and maximum bet amounts
- `config.stepBet` increment

The frontend must respect these values:

- Bet increments must reflect `config.stepBet`.
- Minimum and maximum bet levels must be selectable as dictated by the RGS.
- Hardcoded bet amounts cause `/wallet/play` to fail. Example: a default of 1 unit when the session currency is JPY (minimum 10 units) will be rejected.

## RGS URL Handling

- The RGS hostname must be read from the `rgs_url` query parameter on every game load.
- The `rgs_url` value differs between staging, production, and replay environments. It **must not be hardcoded** in the build.

## Currency Enforcement

- The session currency is returned in `balance.currency` from `/wallet/authenticate`.
- Bet amounts must be within the supported range for that currency.
- All monetary values are integers in minor currency units with 6 decimal places of precision (e.g. `1000000` = 1.00).
- For the full supported currency list and display formatting, see `reference-locales.md`.

## Language Enforcement

- The `lang` URL query parameter dictates display language.
- **English (`en`) is the only required language.** If only English is supported, the game must not break or render corrupted text when other `lang` codes are passed.
- For supported language codes, see `reference-locales.md`.

## XSS Policy

- Stake Engine enforces a strict XSS policy.
- The build must consist only of static files.
- External resources (fonts, scripts, images) loaded from origins outside the Stake Engine CDN will log console errors and fail approval.
