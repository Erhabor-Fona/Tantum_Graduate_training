import '../core/network/api_client.dart';
import '../data/repositories/http_auth_repository.dart';
import '../data/repositories/http_banking_repositories.dart';
import '../data/repositories/http_engagement_repositories.dart';
import '../data/repositories/mock_auth_repository.dart';
import '../data/repositories/mock_banking_repositories.dart';
import '../data/repositories/mock_engagement_repositories.dart';
import '../data/repositories/shared_preferences_session_store.dart';
import '../domain/repositories/account_repository.dart';
import '../domain/repositories/airtime_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/repositories/session_store.dart';
import '../domain/repositories/support_repository.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/repositories/transfer_repository.dart';
import '../domain/services/date_formatter.dart';
import '../domain/services/input_validator.dart';
import '../domain/services/money_formatter.dart';
import '../domain/services/password_policy.dart';
import 'app_config.dart';

/// The composition root: the single place where abstractions are bound to
/// concrete classes.
///
/// DIP in practice — every field below is declared as an interface. Providers
/// and screens receive these interfaces and never construct a repository
/// themselves, so swapping mock for HTTP (or injecting a fake in a test) is a
/// one-line change here.
class Dependencies {
  final SessionStore sessionStore;
  final AuthRepository authRepository;
  final AccountRepository accountRepository;
  final TransactionRepository transactionRepository;
  final TransferRepository transferRepository;
  final AirtimeRepository airtimeRepository;
  final NotificationRepository notificationRepository;
  final SupportRepository supportRepository;

  final PasswordPolicy passwordPolicy;
  final MoneyFormatter money;
  final DateFormatterService dates;
  final InputValidator validator;

  const Dependencies({
    required this.sessionStore,
    required this.authRepository,
    required this.accountRepository,
    required this.transactionRepository,
    required this.transferRepository,
    required this.airtimeRepository,
    required this.notificationRepository,
    required this.supportRepository,
    required this.passwordPolicy,
    required this.money,
    required this.dates,
    required this.validator,
  });

  /// Builds the graph the running app uses.
  factory Dependencies.resolve({bool? useMockApi}) {
    final mock = useMockApi ?? AppConfig.useMockApi;

    if (mock) {
      return Dependencies(
        sessionStore: SharedPreferencesSessionStore(),
        authRepository: MockAuthRepository(),
        accountRepository: MockAccountRepository(),
        transactionRepository: MockTransactionRepository(),
        transferRepository: MockTransferRepository(),
        airtimeRepository: MockAirtimeRepository(),
        notificationRepository: MockNotificationRepository(),
        supportRepository: MockSupportRepository(),
        passwordPolicy: const TatumPasswordPolicy(),
        money: NairaFormatter(),
        dates: const AppDateFormatter(),
        validator: const AppInputValidator(),
      );
    }

    final ApiClient client = HttpApiClient(baseUrl: AppConfig.apiBaseUrl);
    return Dependencies(
      sessionStore: SharedPreferencesSessionStore(),
      // Live: auth, accounts, products and purchases.
      authRepository: HttpAuthRepository(client),
      accountRepository: HttpAccountRepository(client),
      transactionRepository: HttpTransactionRepository(client),
      airtimeRepository: HttpAirtimeRepository(client),
      // Still mocked: the TatumConnect API exposes no endpoints for transfers,
      // notifications or support tickets yet. Swapping each one to its Http*
      // counterpart is a one-line change here once the backend ships them —
      // that is the whole point of the composition root.
      transferRepository: MockTransferRepository(),
      notificationRepository: MockNotificationRepository(),
      supportRepository: MockSupportRepository(),
      passwordPolicy: const TatumPasswordPolicy(),
      money: NairaFormatter(),
      dates: const AppDateFormatter(),
      validator: const AppInputValidator(),
    );
  }
}
