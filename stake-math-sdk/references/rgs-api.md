# RGS HTTP API Reference

Complete contract for the Stake Engine RGS (Remote Game Server) HTTP API.

**Base URL**: `https://rgs.stake-engine.com` (production). The actual host **must** be read from the `rgs_url` URL query parameter — do not hardcode.

All monetary values are integers in **minor currency units** with **6 decimal places** of precision. Example: `1000000` = 1.00 USD.

## Table of Contents

- [Endpoints Overview](#endpoints-overview)
- [Authentication Model](#authentication-model)
- [Error Codes](#error-codes)
- [POST /wallet/authenticate](#post-walletauthenticate)
- [POST /wallet/balance](#post-walletbalance)
- [POST /wallet/play](#post-walletplay)
- [POST /wallet/end-round](#post-walletend-round)
- [POST /bet/event](#post-betevent)
- [GET /bet/replay/{game}/{version}/{mode}/{event}](#get-betreplaygameversionmodeevent)

## Endpoints Overview

| Method | Path | Description |
|--------|------|-------------|
| POST | `/wallet/authenticate` | Validate a session and retrieve balance, game config, and jurisdiction settings. |
| POST | `/wallet/balance` | Retrieve the player's current balance. |
| POST | `/wallet/play` | Initiate a round and debit the bet amount. |
| POST | `/wallet/end-round` | Complete a round and trigger payout. |
| POST | `/bet/event` | Track in-progress player actions during a round. |
| GET | `/bet/replay/{game}/{version}/{mode}/{event}` | Fetch replay data for a completed round. |

## Authentication Model

All `/wallet/*` endpoints and `/bet/event` require a `sessionID` in the request body. The session is issued by the operator platform and arrives via the `sessionID` URL query parameter on game load. It must be validated via `/wallet/authenticate` before any other endpoint is called.

`/bet/replay/...` does **not** require a session — replay URLs are publicly shareable.

Re-calling `/wallet/authenticate` with the same `sessionID` is safe: it returns the current state and does not create a duplicate session or reset the active round.

## Error Codes

### 400 — Client Errors

| Code | Description |
|------|-------------|
| `ERR_VAL` | Invalid request. |
| `ERR_IPB` | Insufficient player balance. |
| `ERR_IS` | Invalid session token / session timeout. |
| `ERR_ATE` | Failed user authentication / token expired. |
| `ERR_GLE` | Gambling limits exceeded. |
| `ERR_LOC` | Invalid player location. |

### 500 — Server Errors

| Code | Description |
|------|-------------|
| `ERR_GEN` | General server error. |
| `ERR_MAINTENANCE` | RGS under planned maintenance. |

### 404 — Replay-specific

| Code | Description |
|------|-------------|
| `NOT_FOUND` | Replay data not found for the given game/version/mode/event combination. |

## POST /wallet/authenticate

Validates the session and returns balance, configuration, and any active round.

### Request

```json
{
  "sessionID": "string"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `sessionID` | string | Yes | Session ID from the URL query parameter. |

### Response — 200 OK

```json
{
  "balance": { "amount": 1000000000, "currency": "USD" },
  "round": null,
  "config": {
    "gameID": "",
    "minBet": 100000,
    "maxBet": 10000000,
    "stepBet": 100000,
    "defaultBetLevel": 1000000,
    "betLevels": [100000, 200000, 400000, 1000000, 10000000],
    "betModes": {},
    "jurisdiction": {
      "socialCasino": false,
      "disabledFullscreen": false,
      "disabledTurbo": false,
      "disabledSuperTurbo": false,
      "disabledAutoplay": false,
      "disabledSlamstop": false,
      "disabledSpacebar": false,
      "disabledBuyFeature": false,
      "displayNetPosition": false,
      "displayRTP": false,
      "displaySessionTimer": false,
      "minimumRoundDuration": 0
    }
  },
  "meta": null
}
```

| Field | Type | Description |
|-------|------|-------------|
| `balance.amount` | integer | Balance in minor currency units. |
| `balance.currency` | string | ISO 4217 currency code (or platform-specific code for virtual currencies). |
| `round` | object \| null | Active or last completed round, if any. `null` otherwise. If present, the frontend should continue/resume the round. |
| `config.gameID` | string | Game identifier for this session. |
| `config.minBet` | integer | Minimum allowed bet. |
| `config.maxBet` | integer | Maximum allowed bet. |
| `config.stepBet` | integer | Bet increment step. |
| `config.defaultBetLevel` | integer | Default bet on session start. |
| `config.betLevels` | integer[] | All available bet levels. |
| `config.betModes` | object | Game-specific betmode configuration. |
| `config.jurisdiction` | object | Per-source docs: ignore — not in use. |
| `meta` | any | Per-source docs: ignore — not in use. |

Zero-payout rounds are auto-completed by the RGS. If `round` is `null` despite recent play, the round had a zero payout and is already closed.

### Errors

| Status | Code | Notes |
|--------|------|-------|
| 401 | `ERR_IS` | Session missing, expired, or invalid. |
| 500 | `ERR_GEN` | Unexpected server error. |

## POST /wallet/balance

Returns the player's current balance.

### Request

```json
{
  "sessionID": "string"
}
```

### Response — 200 OK

```json
{
  "balance": { "amount": 1000000000, "currency": "USD" }
}
```

### Errors

| Status | Code | Notes |
|--------|------|-------|
| 401 | `ERR_IS` | Invalid or expired session. |
| 500 | `ERR_GEN` | Server error. |

## POST /wallet/play

Initiates a round and debits the bet amount. Returns the round result.

### Request

```json
{
  "sessionID": "string",
  "amount": 1000000,
  "mode": "BASE"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `sessionID` | string | Yes | Session ID. |
| `amount` | integer | Yes | Bet amount in minor currency units. Must be within `config.minBet`..`config.maxBet`. |
| `mode` | string | Yes | Betmode identifier (e.g. `BASE`, `SUPER`). Must be a valid mode for the game. |

### Response — 200 OK

```json
{
  "balance": { "amount": 999000000, "currency": "USD" },
  "round": {
    "payoutMultiplier": 2.5,
    "costMultiplier": 1.0,
    "state": {}
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `balance.amount` | integer | Balance after the bet is debited. |
| `round.payoutMultiplier` | float | Multiplier applied to the bet for total payout. |
| `round.costMultiplier` | float | Multiplier applied for total bet cost. |
| `round.state` | object | Game-specific state for rendering the round (matches the book event payload). |

If `payoutMultiplier` is 0, the round is auto-completed by the RGS — no `end-round` call needed. If non-zero, the round remains active until `end-round` is called.

### Errors

| Status | Code | Notes |
|--------|------|-------|
| 400 | `ERR_VAL` | Invalid parameters. |
| 400 | `ERR_IPB` | Insufficient balance. |
| 401 | `ERR_IS` | Invalid session. |
| 500 | `ERR_GEN` | Server error. |

## POST /wallet/end-round

Completes an active round and credits winnings to the player. Required only for rounds with `payoutMultiplier > 0`.

### Request

```json
{
  "sessionID": "string"
}
```

### Response — 200 OK

```json
{
  "balance": { "amount": 1002500000, "currency": "USD" }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `balance.amount` | integer | Updated balance after payout credit. |

Call this after all in-round activity completes (including bonus rounds, free spins, etc.).

### Errors

| Status | Code | Notes |
|--------|------|-------|
| 401 | `ERR_IS` | Invalid session. |
| 500 | `ERR_GEN` | Server error. |

## POST /bet/event

Records an in-round event for state recovery. Allows the frontend to reconstruct round progress after disconnection.

### Request

```json
{
  "sessionID": "string",
  "event": "string"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `sessionID` | string | Yes | Session ID. |
| `event` | string | Yes | Event identifier representing the player action. |

A session must be authenticated and a round must be in progress.

### Response — 200 OK

```json
{
  "event": "event_id_here"
}
```

### Errors

| Status | Code | Notes |
|--------|------|-------|
| 401 | `ERR_IS` | Invalid session. |
| 500 | `ERR_GEN` | Server error. |

## GET /bet/replay/{game}/{version}/{mode}/{event}

Fetches the data needed to replay a previously played round. No session required.

### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `game` | string | Game identifier (UUID). |
| `version` | string | Math version of the game. |
| `mode` | string | Betmode used in the round. |
| `event` | string | Unique simulation/event ID to replay. |

### Response — 200 OK

```json
{
  "payoutMultiplier": 25.0,
  "costMultiplier": 1.0,
  "state": {}
}
```

| Field | Type | Description |
|-------|------|-------------|
| `payoutMultiplier` | float | Multiplier for total payout from bet amount. |
| `costMultiplier` | float | Multiplier for bet cost. |
| `state` | object | Game-specific state for replaying the round animation. |

### Errors

| Status | Code | Notes |
|--------|------|-------|
| 404 | `NOT_FOUND` | No replay data for the given combination. |
| 500 | `ERR_GEN` | Server error. |

### Replay-Mode URL Query Parameters

When the game loads in replay mode (in addition to standard URL parameters):

| Parameter | Required | Description |
|-----------|----------|-------------|
| `replay` | Yes | Always `true`. |
| `game` | Yes | Game UUID. |
| `version` | Yes | Math version. |
| `mode` | Yes | Betmode used. |
| `event` | Yes | Event/simulation ID. |
| `rgs_url` | Yes | RGS host for the replay fetch. |
| `currency` | No | For display formatting. |
| `amount` | No | Bet amount in raw units. |
| `lang` | No | Language code. |
| `device` | No | `desktop` or `mobile`. |
| `social` | No | `true` or `false`. |
