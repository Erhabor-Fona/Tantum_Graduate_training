# Tatum Bank — Flutter Capstone Project

**All-in-One Banking, All for You.**

Capstone for the **Techware Academy 6-Week Graduate Trainee Programme
(Mobile Development / Flutter)**. It implements the Tatum Bank Figma designs
as a complete, responsive Flutter application built on a **SOLID, layered
architecture** — see [`ARCHITECTURE.md`](ARCHITECTURE.md).

## Getting started

```bash
flutter create .     # generate android/, ios/ (first time only)
flutter pub get
flutter run
```

`AppConfig.useMockApi` is `true`, so the app runs fully offline on demo data.

- **Log in:** any valid email/phone + any 8+ character password
- **OTP:** any 6 digits except `000000`
- **Transfers:** enter a 10-digit account number to resolve a recipient name.
  Sending more than the balance triggers the Transfer Failed screen.

## Screens

| Flow | Screens |
|---|---|
| Onboarding | Splash M01, Welcome M02 |
| Auth | Create Account, Verify Your Identity (+ error state), Welcome Back (+ email/password error states), Forgot Password, Create New Password, Password Reset Successful |
| Dashboard | Home Dashboard V2 inside a five-tab shell |
| Transactions | Transaction History M10 (All/Pending/Successful/Failed), Transaction Details, New Transfer, Transfer Success, Transfer Failed |
| Airtime & Data | Buy Airtime home, Buy Airtime & Data, Purchase Successful, Purchase Failed |
| Notifications | Notifications, Notification Detail, Notification Preferences |
| Support | Support Home M18, Create Service Request (3-step), Request Details, Request Status |
| Account | Account Information, Account Limits & KYC |
| Profile | Profile & Settings M11, Security & Privacy, Edit Profile (+ disabled state) |
| States | Loading, empty, error and not-found views |

## Design tokens

| Token | Value | Use |
|---|---|---|
| Primary | `#FFCC33` | Brand yellow — balance card, primary buttons, brand app bar |
| Gold | `#FFD700` | Accent, pending status |
| Navy | `#001F3F` | Headings, dark buttons, account cards |
| Success | `#27AE60` | Successful states |
| Danger | `#FF0000` | Failures, destructive actions |
| Tints | `#27AE6033` `#FF000033` `#00FF0033` `#FFCC0033` `#F3F4F666` | Badges, chips, soft banners |
| Info | `#F0F7FF` | Advisory callouts |

## Project structure

```
lib/
├── main.dart          Composition root
├── app/               Config, palette, spacing, theme, routes, DI
├── domain/            Entities, repository contracts, pure services
├── data/              Mock + HTTP repository implementations
├── core/              Errors, HTTP client, extensions
├── providers/         ChangeNotifiers (UI state)
├── screens/           One folder per flow
└── widgets/           Shared, reusable components
```

## Connecting a real backend

Set `AppConfig.useMockApi = false` and point `AppConfig.apiBaseUrl` at the
server. Nothing else changes — the composition root swaps `Mock*` repositories
for `Http*` ones behind the same interfaces.

## Building a release APK

```bash
flutter build apk --release
# build/app/outputs/flutter-apk/app-release.apk
```

## Team workflow

- One feature branch per screen or flow (`feature/buy-airtime`)
- Conventional commits (`feat:`, `fix:`, `docs:`)
- Peer-reviewed pull requests into `main`

---
*Techware Academy — Tatum Bank Graduate Trainee Tech Programme, 2026.*
