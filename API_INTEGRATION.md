# TatumConnect API Integration

Base URL `https://tatumconnect-backend.onrender.com`
Toggle: `lib/app/app_config.dart` → `AppConfig.useMockApi`
(`false` = live, `true` = offline demo data).

The SOLID architecture is untouched. Only the `Http*` repositories were
implemented — every provider and screen is unchanged, because they depend on
the abstract repository interfaces, not on these classes.

## What runs live

| Area | Repository | Endpoints |
|---|---|---|
| Auth | `HttpAuthRepository` | `POST /api/v1/Auth/register` · `verify-registration` · `resend-registration-otp` · `login` · `reset-password-start` · `reset-password`, `GET /api/v1/Auth/me` |
| Accounts | `HttpAccountRepository` | `GET /api/v1/Accounts`, `PUT /api/v1/Users/profile` |
| Transactions | `HttpTransactionRepository` | `GET /api/v1/transactions` |
| Airtime & Data | `HttpAirtimeRepository` | `GET /api/Products/billers` · `billers/{id}/products` · `{productId}/items`, `POST /api/v1/transactions/purchase` |

## What stays mocked

Transfers, notifications and support tickets have **no endpoints in this
API**. `Dependencies.resolve()` binds those three to their `Mock*`
implementations so the screens still work. Swapping each to `Http*` is a
one-line change in the composition root once the backend ships them.

## The empty-token bug

The OpenAPI document declares `200` with **no response schema** for every
`/Auth` endpoint, so the location of the JWT is not contractual. The previous
integration read a hard-coded `data.token`, which did not match, stored `""`,
and every authenticated request then went out unauthorised.

Three defences:

1. **`lib/core/network/json_probe.dart`** — `JsonProbe.findToken()` walks the
   whole decoded tree for `accessToken` / `access_token` / `token` / `jwt` /
   `idToken` / `id_token` / `authToken` / `bearerToken` at any depth, and logs
   the JSON path it matched (`✓ token found at $.data.accessToken`). If it
   finds nothing it dumps the entire response tree.
2. **`HttpAuthRepository` throws instead of returning an empty token**, so a
   shape mismatch fails at login rather than silently later.
3. **`SharedPreferencesSessionStore.saveToken()` refuses empty strings and
   reads the value back** to prove the write landed.

## Registration

`register` and `verify-registration` both return empty `200`s, so verification
may not issue a token. `HttpAuthRepository.verifyOtp()` handles both: it uses
a token if one is present, otherwise it logs in with the password captured
during `register()`. The caller always receives a usable `AuthSession`.

## Purchases

`ProductPurchaseRequestDto` needs `accountId`. It is captured from
`GET /api/v1/Accounts` and cached in
`HttpAccountRepository.cachedAccountId`; if it is missing the repository
raises a readable `ValidationException` rather than posting an empty UUID.

The domain speaks `TelcoNetwork` + `PurchaseType`; the API speaks
Biller → Product → Item. `HttpAirtimeRepository` translates by matching the
biller name against the telco label and the product category against
`Airtime`/`Data`, caching both lookups.

Airtime sends `amount` with `productItemId: null`.
Data sends the chosen `productItemId` plus its price as `amount`.

## Debug output

Every request logs under the `API` tag:

```
┌──────────────────────────────────────────────
│ → POST /api/v1/Auth/login
│   BASE URL : https://tatumconnect-backend.onrender.com
│   ENDPOINT : /api/v1/Auth/login
│   FULL URL : https://tatumconnect-backend.onrender.com/api/v1/Auth/login
│   HEADERS  : { "Content-Type": "application/json", … }
│   BODY     : { "email": "…", "password": "…" }
│ ← STATUS   : 200  (412ms)
│ ← RESPONSE : { … }
└──────────────────────────────────────────────
```

Other tags: `AUTH`, `SESSION`, `ACCOUNT`, `PRODUCT`, `TXN`.
Authorization headers are truncated so tokens never land in a shared log.
