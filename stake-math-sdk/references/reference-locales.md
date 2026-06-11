# Reference — Locales and URL Structure

Supported currencies, languages, viewport dimensions, social-mode rules, and game launch URL structure.

## Table of Contents

- [Game Launch URL](#game-launch-url)
- [Query Parameters](#query-parameters)
- [Money and Precision](#money-and-precision)
- [Fiat Currencies](#fiat-currencies)
- [Virtual Currencies](#virtual-currencies)
- [Languages](#languages)
- [Viewport Dimensions](#viewport-dimensions)
- [Social Mode](#social-mode)

## Game Launch URL

```
https://{team}.live.stake-engine.com/{game}/v{version}/?sessionID=...&rgs_url=...&lang=...&currency=...&device=...&social=...&demo=...
```

Path segments:

| Segment | Description |
|---------|-------------|
| `{team}` | Studio/team name, assigned at onboarding. |
| `{game}` | Game slug (e.g. `treasure-hunt`). |
| `v{version}` | Frontend version number (e.g. `v1`, `v2`). |

## Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `sessionID` | string | Yes | Unique player session token. Used for all RGS API calls. |
| `rgs_url` | string | Yes | RGS server hostname. **Do not hardcode** — differs between staging, production, and replay. |
| `lang` | string | Yes | Display language (ISO 639-1 code). |
| `currency` | string | Yes | Currency code for display formatting. |
| `device` | string | Yes | `desktop` or `mobile`. |
| `social` | boolean | Yes | `true` when loaded in social casino context (Stake.us). |
| `demo` | boolean | No | `true` for demo/free-play mode (no real balance affected). |
| `replay` | boolean | No | `true` in replay mode. Adds `game`, `version`, `mode`, `event` parameters. |

Parsing example:

```typescript
const params = new URLSearchParams(window.location.search);
const sessionID = params.get('sessionID')!;
const rgsUrl    = `https://${params.get('rgs_url')}`;
const lang      = params.get('lang') ?? 'en';
const currency  = params.get('currency') ?? 'USD';
const device    = params.get('device') ?? 'desktop';
const social    = params.get('social') === 'true';
const demo      = params.get('demo') === 'true';
const replay    = params.get('replay') === 'true';
```

## Money and Precision

All monetary values in the API are **integers** with **6 decimal places** of precision. The currency code is returned in `balance.currency`.

| Raw Value | Actual Amount |
|-----------|---------------|
| `100000` | 0.10 |
| `1000000` | 1.00 |
| `10000000` | 10.00 |
| `100000000` | 100.00 |
| `1000000000` | 1,000.00 |

A $1 bet uses `amount: 1000000` regardless of currency. Currency affects only the display layer.

## Fiat Currencies

| Currency | Code | Symbol | Display Decimals | Example |
|----------|------|--------|------------------|---------|
| United States Dollar | `USD` | $ | 2 | $10.00 |
| Canadian Dollar | `CAD` | CA$ | 2 | CA$10.00 |
| Japanese Yen | `JPY` | ¥ | 0 | ¥10 |
| Euro | `EUR` | € | 2 | €10.00 |
| Russian Ruble | `RUB` | ₽ | 2 | ₽10.00 |
| Chinese Yuan | `CNY` | CN¥ | 2 | CN¥10.00 |
| Philippine Peso | `PHP` | ₱ | 2 | ₱10.00 |
| Indian Rupee | `INR` | ₹ | 2 | ₹10.00 |
| Indonesian Rupiah | `IDR` | Rp | 0 | Rp10 |
| South Korean Won | `KRW` | ₩ | 0 | ₩10 |
| Brazilian Real | `BRL` | R$ | 2 | R$10.00 |
| Mexican Peso | `MXN` | MX$ | 2 | MX$10.00 |
| Danish Krone | `DKK` | KR | 2 | 10.00 KR |
| Polish Złoty | `PLN` | zł | 2 | 10.00 zł |
| Vietnamese Đồng | `VND` | ₫ | 0 | 10 ₫ |
| Turkish Lira | `TRY` | ₺ | 2 | ₺10.00 |
| Chilean Peso | `CLP` | CLP | 0 | 10 CLP |
| Argentine Peso | `ARS` | ARS | 2 | 10.00 ARS |
| Peruvian Sol | `PEN` | S/ | 2 | S/10.00 |
| Nigerian Naira | `NGN` | ₦ | 2 | ₦10.00 |
| Saudi Arabia Riyal | `SAR` | SAR | 2 | 10.00 SAR |
| Israel Shekel | `ILS` | ILS | 2 | 10.00 ILS |
| United Arab Emirates Dirham | `AED` | AED | 2 | 10.00 AED |
| Taiwan New Dollar | `TWD` | NT$ | 2 | NT$10.00 |
| Norway Krone | `NOK` | kr | 2 | kr10.00 |
| Kuwaiti Dinar | `KWD` | KD | 2 | KD10.00 |
| Jordanian Dinar | `JOD` | JD | 2 | JD10.00 |
| Costa Rica Colon | `CRC` | ₡ | 2 | ₡10.00 |
| Tunisian Dinar | `TND` | TND | 2 | 10.00 TND |
| Singapore Dollar | `SGD` | SG$ | 2 | SG$10.00 |
| Malaysia Ringgit | `MYR` | RM | 2 | RM10.00 |
| Oman Rial | `OMR` | OMR | 2 | 10.00 OMR |
| Qatar Riyal | `QAR` | QAR | 2 | 10.00 QAR |
| Bahraini Dinar | `BHD` | BD | 2 | BD10.00 |

## Virtual Currencies

Used on Stake.us social casino. Values are displayed **without** a `$` prefix.

| Currency | Code | Symbol | Display Decimals | Example |
|----------|------|--------|------------------|---------|
| Stake Gold Coin | `XGC` | GC | 2 | 10.00 GC |
| Stake Cash | `XSC` | SC | 2 | 10.00 SC |

## Languages

The `lang` URL query parameter dictates display language. English (`en`) is the only required language. If only English is supported, on-screen text must not corrupt when other codes are passed.

| Language | Code |
|----------|------|
| Arabic | `ar` |
| Chinese | `zh` |
| English | `en` |
| Finnish | `fi` |
| French | `fr` |
| German | `de` |
| Hindi | `hi` |
| Indonesian | `id` |
| Japanese | `ja` |
| Korean | `ko` |
| Polish | `po` |
| Portuguese | `pt` |
| Russian | `ru` |
| Spanish | `es` |
| Turkish | `tr` |
| Vietnamese | `vi` |

## Viewport Dimensions

The `device` query parameter indicates the device type. The game must adapt to the corresponding viewport.

| Mode | Width | Height | Aspect Ratio |
|------|------:|-------:|--------------|
| Desktop | 1200 | 675 | 16:9 |
| Laptop | 1024 | 576 | 16:9 |
| Popout L | 800 | 450 | 16:9 |
| Popout S | 400 | 225 | 16:9 |
| Mobile L | 425 | 812 | ~1:1.9 |
| Mobile M | 375 | 667 | ~9:16 |
| Mobile S | 320 | 568 | ~9:16 |

Mini-player (popout) modes must render without distorting the active game board.

## Social Mode

Indicated by the `social=true` URL query parameter. Applies to games on stake.us. The `lang` parameter is still sent normally; there is no special language code for social mode. In social mode, English with the replacements below must be used regardless of `lang`.

Games containing any restricted phrase below in rules, images, or UI elements will not be approved for stake.us.

### Restricted Phrase Replacements

| Restricted Phrase | Replacement |
|-------------------|-------------|
| bet | play |
| bets | plays |
| bet/s | play/s |
| betting | playing |
| bonus buy | bonus / feature |
| bought | instantly triggered |
| buy | play |
| buy bonus | get bonus |
| cash | coins |
| cost of | can be played for |
| at the cost of | for |
| credit | coins |
| currency | token |
| deposit | get coins |
| gamble | play |
| loss limit | stop limit |
| loss streak | miss streak |
| money | coins |
| paid | won |
| paid out | won |
| pay | win |
| pay out | win / won |
| pay table | win table |
| payer | winner |
| pays | wins |
| pays out | win |
| place your bets | come and play / join in the game |
| profit | net gain |
| purchase | play |
| rebet | respin |
| stake | play amount |
| total bet | total play |
| wager | play |
| win feature | play feature |
| withdraw | redeem |
| be awarded to player's accounts | appear in player's accounts |
