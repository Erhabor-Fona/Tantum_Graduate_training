# Architecture

Tatum Bank is built around the five SOLID principles. This document explains
where each one shows up, so trainees can point at real code rather than a
textbook example.

## Layers

```
screens/  widgets/          presentation      Flutter only
      |
providers/                  state            ChangeNotifier
      |
domain/                     contracts        pure Dart, no Flutter import
      |
data/                       implementations  mock and HTTP
      |
core/                       plumbing         exceptions, HTTP client
```

Dependencies point downward only. `domain/` imports nothing from `data/`, and
no screen imports a concrete repository. That rule is mechanically checkable:

```bash
grep -r "data/" lib/screens lib/providers --include=*.dart
```

should return nothing.

## Single Responsibility

Every class has one reason to change.

- `AppColors` holds colour values; `AppTheme` decides how they are applied.
  A rebrand touches the first, a restyle touches the second.
- `MockData` supplies fixtures and nothing else. When the live API is ready the
  whole file is deleted without touching a screen.
- `AsyncState` (in `providers/view_state.dart`) owns loading and error
  bookkeeping. Each provider mixes it in and is left with only its own logic.
- `TransactionProvider` filters an already-loaded list. Tapping a filter chip
  never triggers a network call.
- `AppRoutes` maps a name to a screen. It builds no UI itself.

## Open for extension, closed for modification

New behaviour arrives as new code, not edits to working code.

- `TelcoNetwork` is an enum carrying its own brand colours. Supporting a fifth
  network is one new enum value; the picker, the receipts and the history tiles
  all pick it up because they iterate `TelcoNetwork.values`.
- `NotificationPreferences` stores a flat `Map<String, bool>`. Adding a
  preference is one key plus one row in the section table in
  `notification_preferences_screen.dart`.
- `PasswordPolicy` is an interface. Tightening the bank's rules means writing a
  new implementation and binding it in the composition root — the reset
  password screen is untouched.
- `StatusBadge` switches over `TransactionStatus`, so a new status is handled in
  one widget rather than at every call site.

## Liskov substitution

Any implementation of a contract can replace any other.

`MockAuthRepository` and `HttpAuthRepository` both implement `AuthRepository`.
They return the same types and throw the same exception types for the same
failures — a short password raises `AuthException` in both. `AuthProvider`
cannot tell which one it holds, which is exactly why flipping
`AppConfig.useMockApi` works.

`test/repository_substitution_test.dart` runs the identical test body against
two implementations to prove this holds.

## Interface segregation

Contracts are small, so nothing depends on methods it does not use.

- `SessionStore` is separate from `AuthRepository`. A widget that only reads the
  dark mode flag does not gain access to `login` and `verifyOtp`.
- `TransactionRepository` (read) is separate from `TransferRepository` (write).
  The history screen literally cannot move money.
- `AirtimeRepository`, `NotificationRepository` and `SupportRepository` are
  independent rather than one `BankingRepository` with twenty methods.

A single fat repository would force every provider to be rebuilt and re-mocked
whenever any unrelated method changed.

## Dependency inversion

High-level code depends on abstractions; the concrete choice is made once.

`lib/app/dependencies.dart` is the composition root and the only file in the
project that names a concrete repository:

```dart
factory Dependencies.resolve({bool? useMockApi}) {
  final mock = useMockApi ?? AppConfig.useMockApi;
  if (mock) {
    return Dependencies(authRepository: MockAuthRepository(), ...);
  }
  final ApiClient client = HttpApiClient(baseUrl: AppConfig.apiBaseUrl);
  return Dependencies(authRepository: HttpAuthRepository(client), ...);
}
```

Every field on `Dependencies` is declared as an interface. `main.dart` builds
the graph once and hands it to the provider tree. Screens read formatters and
validators through `context.read<Dependencies>()`, so a test can substitute the
entire backend in one line:

```dart
TatumBankApp(dependencies: Dependencies.resolve(useMockApi: true));
```

Repositories also depend on the `ApiClient` interface rather than
`package:http`, so switching HTTP libraries is a change in `core/network/`
alone.

## Error handling

`core/error/app_exception.dart` defines a sealed hierarchy. Repositories throw
these; providers catch them in one place and convert them into `ViewState.error`
plus a message. Screens render that state through `StateSwitcher`, which means
no screen contains a try/catch and every screen handles loading, empty and
error states the same way.

## State management

`provider` with `ChangeNotifier`. Providers are created in `main.dart` and are
long-lived. `context.watch` is used where a rebuild is wanted; `context.read` is
used for one-shot reads, including the route guard in `AppRoutes` — using
`watch` there would rebuild the route and loop.

## One screen per outcome pair

The success and failure designs share a skeleton, so `TransferResultScreen` and
`PurchaseResultScreen` each render both outcomes and branch on what the route
was given: a `TransferReceipt` / `PurchaseReceipt` means success, a failure map
means the error variant. Two near-identical screens would drift apart the first
time a field was added.

---

# Appendix

## Annotated file tree
```
lib/
├── main.dart                     Composition root — builds the object graph
├── app/                          Cross-cutting app configuration
│   ├── app_config.dart           Build-time flags (mock vs live API)
│   ├── app_colors.dart           Palette only
│   ├── app_spacing.dart          Spacing & radii only
│   ├── app_theme.dart            Turns colours + spacing into ThemeData
│   ├── app_routes.dart           Route name → screen, plus the auth guard
│   └── dependencies.dart         Binds interfaces to implementations
│
├── domain/                       Pure Dart. No Flutter, no http, no storage.
│   ├── entities/                 User, Account, BankTransaction, Telco, …
│   ├── repositories/             ABSTRACT contracts the app depends on
│   └── services/                 MoneyFormatter, DateFormatter,
│                                 InputValidator, PasswordPolicy
│
├── data/                         Everything that talks to the outside world
│   ├── sources/mock_data.dart    Canned demo data
│   └── repositories/             Http* and Mock* implementations of the
│                                 domain contracts
│
├── core/
│   ├── error/app_exception.dart  One sealed error type for the whole app
│   ├── network/api_client.dart   HTTP transport + status→exception mapping
│   └── extensions/               Small BuildContext conveniences
│
├── providers/                    ChangeNotifiers — UI state only
└── screens/ + widgets/           Flutter. Renders state, raises intents.
```
## Switching to a live backend

1. Point `AppConfig.apiBaseUrl` at the server.
2. Set `AppConfig.useMockApi = false`.

That is the entire change. `Dependencies.resolve()` returns the `Http*`
repositories instead of the `Mock*` ones, and because both satisfy the same
contracts (Liskov), nothing above the data layer notices.

---

## Where the syllabus concepts live

| Week · Session | Concept | File(s) |
|---|---|---|
| W2 S4–6 | Widgets, layouts, themes, reusable components | `app/app_theme.dart`, `widgets/` |
| W3 S7 | Named routes, arguments, not-found route | `app/app_routes.dart` |
| W3 S8 | Forms and validation | `domain/services/input_validator.dart`, `screens/auth/` |
| W3 S9 | Dialogs, sheets, snackbars, app states | `widgets/state_views.dart`, `screens/dashboard/` |
| W4 S10–11 | Stateful widgets, Provider, ChangeNotifier | `providers/` |
| W4 S12 | Local storage | `data/repositories/shared_preferences_session_store.dart` |
| W5 S13–14 | REST, JSON models, service classes, errors | `core/network/`, `data/repositories/http_*` |
| W5 S15 | Auth, tokens, protected screens | `providers/auth_provider.dart`, route guard |
| W6 S17 | Testing | `test/` |
