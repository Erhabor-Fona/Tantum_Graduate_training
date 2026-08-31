import '../../domain/entities/account.dart';
import '../../domain/entities/account_limit.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/bank_transaction.dart';
import '../../domain/entities/data_plan.dart';
import '../../domain/entities/support_request.dart';
import '../../domain/entities/telco.dart';
import '../../domain/entities/transaction_status.dart';
import '../../domain/entities/transfer.dart';
import '../../domain/entities/user.dart';

/// Demo fixtures matching the Figma designs.
///
/// SRP: this file only supplies data. Nothing here knows about HTTP, widgets
/// or navigation, so the whole mock layer can be deleted when a live backend
/// is ready without touching another file.
class MockData {
  MockData._();

  static const user = User(
    id: 'usr_001',
    fullName: 'Sarima Hassan',
    email: 'sarima.hassan@email.com',
    phone: '0806 123 4567',
    dateOfBirth: '12 March 1990',
    address: '12 Ahmed Onibudo Street, Victoria Island, Lagos, Nigeria',
  );

  static const account = Account(
    id: 'acc_001',
    accountNumber: '7099887766',
    accountType: 'Savings Account',
    balance: 165700.00,
    bvnMasked: '**** **** 3456',
    currency: 'NGN',
    dateOpened: '12 Jan 2023',
    status: AccountStatus.active,
  );

  static const limits = <AccountLimit>[
    AccountLimit(name: 'Daily Transfer', limit: 1000000, used: 120000),
    AccountLimit(name: 'Daily Withdrawal', limit: 500000, used: 50000),
    AccountLimit(name: 'Single Transfer', limit: 500000, used: 0),
    AccountLimit(name: 'Airtime Purchase', limit: 50000, used: 5000),
  ];

  static DateTime _at(int daysAgo, int hour, int minute) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - daysAgo, hour, minute);
  }

  static List<BankTransaction> transactions() => [
        BankTransaction(
          id: 'txn_001',
          title: 'Salary Credit',
          amount: 120000,
          direction: TransactionDirection.credit,
          date: _at(0, 8, 35),
          category: TransactionCategory.salary,
          transactionType: 'Direct Deposit (Credit)',
          narration: 'Oct 2023 Monthly Salary',
          reference: 'TRN8293041',
          counterparty: 'Techware Limited',
          counterpartyAccount: 'Savings \u2022 012****345',
          sessionId: '09026723102410240',
        ),
        BankTransaction(
          id: 'txn_002',
          title: 'Transfer to John Doe',
          amount: 25000,
          direction: TransactionDirection.debit,
          date: _at(0, 16, 21),
          transactionType: 'Bank Transfer',
          narration: 'Rent contribution',
          reference: 'TB/20240528/8821',
          counterparty: 'John Doe',
          counterpartyAccount: 'Zenith Bank - 1012345678',
          fee: 50,
          sessionId: '09026723102410241',
        ),
        BankTransaction(
          id: 'txn_003',
          title: 'Buy Airtime - MTN',
          amount: 2000,
          direction: TransactionDirection.debit,
          date: _at(0, 10, 45),
          category: TransactionCategory.airtime,
          transactionType: 'Airtime Purchase',
          narration: 'MTN Airtime Top-up',
          reference: 'TRN8293042',
          channel: 'MTN Nigeria',
          phoneNumber: '0803 123 4567',
        ),
        BankTransaction(
          id: 'txn_004',
          title: 'Share Airtime - Glo',
          amount: 500,
          direction: TransactionDirection.debit,
          date: _at(0, 9, 12),
          category: TransactionCategory.airtime,
          transactionType: 'Airtime Transfer',
          narration: 'Shared airtime',
          reference: 'TRN8293043',
          channel: 'Glo Nigeria',
          phoneNumber: '0805 998 1122',
        ),
        BankTransaction(
          id: 'txn_005',
          title: 'Airtime Received - Airtel',
          amount: 1000,
          direction: TransactionDirection.credit,
          date: _at(0, 8, 5),
          category: TransactionCategory.airtime,
          transactionType: 'Airtime Credit',
          narration: 'Airtime received',
          reference: 'TRN8293044',
          channel: 'Airtel Nigeria',
        ),
        BankTransaction(
          id: 'txn_006',
          title: 'Buy Airtime - 9mobile',
          amount: 3000,
          direction: TransactionDirection.debit,
          date: _at(0, 7, 20),
          category: TransactionCategory.airtime,
          status: TransactionStatus.pending,
          transactionType: 'Airtime Purchase',
          reference: 'TRN8293045',
          channel: '9mobile Nigeria',
          phoneNumber: '0809 555 0100',
        ),
        BankTransaction(
          id: 'txn_007',
          title: 'MTN Data Purchase',
          amount: 1000,
          direction: TransactionDirection.debit,
          date: _at(1, 10, 24),
          category: TransactionCategory.data,
          transactionType: 'Data Purchase',
          narration: 'MTN 1.5GB Monthly Plan',
          reference: 'TRN8293041',
          channel: 'MTN Nigeria',
          phoneNumber: '0803 123 4567',
        ),
        BankTransaction(
          id: 'txn_008',
          title: 'Data Top-up - MTN',
          amount: 5000,
          direction: TransactionDirection.debit,
          date: _at(1, 6, 45),
          category: TransactionCategory.data,
          status: TransactionStatus.failed,
          transactionType: 'Data Purchase',
          narration: 'MTN 10GB Monthly Plan',
          reference: 'TRN8293046',
          channel: 'MTN Nigeria',
          phoneNumber: '0803 123 4567',
        ),
        BankTransaction(
          id: 'txn_009',
          title: 'Phcn Electricity Bill',
          amount: 6500,
          direction: TransactionDirection.debit,
          date: _at(1, 11, 10),
          category: TransactionCategory.bills,
          transactionType: 'Bill Payment',
          narration: 'Prepaid meter top-up',
          reference: 'TRN8293047',
          channel: 'Mobile App',
        ),
        BankTransaction(
          id: 'txn_010',
          title: 'Phcn Electricity Bill',
          amount: 2500,
          direction: TransactionDirection.debit,
          date: _at(2, 11, 10),
          category: TransactionCategory.bills,
          transactionType: 'Bill Payment',
          reference: 'TRN8293048',
        ),
        BankTransaction(
          id: 'txn_011',
          title: 'Airtime Refund',
          amount: 200,
          direction: TransactionDirection.credit,
          date: _at(2, 5, 15),
          category: TransactionCategory.refund,
          transactionType: 'Refund',
          reference: 'TRN8293049',
        ),
        BankTransaction(
          id: 'txn_012',
          title: 'Transfer from Jane Doe',
          amount: 15000,
          direction: TransactionDirection.credit,
          date: _at(3, 6, 45),
          transactionType: 'Bank Transfer',
          reference: 'TRN8293050',
          counterparty: 'Jane Doe',
        ),
      ];

  static const banks = <Bank>[
    Bank(code: '044', name: 'Access Bank'),
    Bank(code: '011', name: 'First Bank'),
    Bank(code: '058', name: 'GTBank'),
    Bank(code: '033', name: 'UBA'),
    Bank(code: '057', name: 'Zenith Bank'),
    Bank(code: '050', name: 'Kuda Bank'),
    Bank(code: '999', name: 'OPay'),
    Bank(code: '998', name: 'PalmPay'),
    Bank(code: '035', name: 'Wema Bank'),
    Bank(code: '232', name: 'Sterling Bank'),
  ];

  static List<DataPlan> dataPlans(TelcoNetwork network) => [
        DataPlan(id: '${network.name}_500mb', network: network, name: '500MB Weekly', price: 500, validity: '7 days'),
        DataPlan(id: '${network.name}_1_5gb', network: network, name: '1.5GB Monthly', price: 1000, validity: '30 days'),
        DataPlan(id: '${network.name}_4_5gb', network: network, name: '4.5GB Monthly', price: 2000, validity: '30 days'),
        DataPlan(id: '${network.name}_10gb', network: network, name: '10GB Monthly', price: 5000, validity: '30 days'),
        DataPlan(id: '${network.name}_25gb', network: network, name: '25GB Monthly', price: 10000, validity: '30 days'),
      ];

  static const quickAmounts = <double>[500, 1000, 2000];

  static List<AppNotification> notifications() => [
        AppNotification(
          id: 'ntf_001',
          kind: NotificationKind.transaction,
          title: 'Data Purchase Successful',
          body: 'You have successfully purchased 1.5GB MTN data for 08012345678.',
          date: DateTime.now().subtract(const Duration(minutes: 2)),
          amount: 1000,
          details: const {
            'Recipient': '08012345678',
            'Network': 'MTN Nigeria',
            'Plan': '1.5GB Monthly',
            'Status': 'Successful',
            'Reference': 'TXN-982347123',
          },
        ),
        AppNotification(
          id: 'ntf_002',
          kind: NotificationKind.balance,
          title: 'Low Balance Alert',
          body: 'Your wallet balance is below \u20A6500. Top up now to stay connected.',
          date: DateTime.now().subtract(const Duration(hours: 1)),
          actionLabel: 'Top Up Now',
        ),
        AppNotification(
          id: 'ntf_003',
          kind: NotificationKind.security,
          title: 'New Security Login',
          body: 'Your account was accessed from a new device (iPhone 13). '
              "If this wasn't you, please change your pin.",
          date: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
          isRead: true,
        ),
        AppNotification(
          id: 'ntf_004',
          kind: NotificationKind.promo,
          title: 'Exclusive Weekend Offer',
          body: 'Get 10% cashback on all airtime purchases above \u20A62,000 this weekend.',
          date: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
          isRead: true,
        ),
      ];

  static List<SupportRequest> supportRequests() => [
        SupportRequest(
          id: 'SR-2024-0512',
          category: 'Transactions',
          issueType: 'Failed Transaction',
          description:
              'I was debited but the payment was not successful. Please reverse the amount.',
          transactionReference: 'TRF0524202412345678',
          attachmentName: 'Receipt.pdf',
          amount: 25000,
          status: RequestStatus.resolved,
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          resolutionNote:
              '\u20A625,000.00 has been successfully reversed to your Savings Account 7099887766.',
          resolvedAt: DateTime.now().subtract(const Duration(hours: 6)),
          timeline: [
            RequestEvent(
              status: RequestStatus.received,
              at: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
              note: 'Your request has been received.',
            ),
            RequestEvent(
              status: RequestStatus.underReview,
              at: DateTime.now().subtract(const Duration(days: 1)),
              note: 'A support agent is reviewing your request.',
            ),
            RequestEvent(
              status: RequestStatus.inProgress,
              at: DateTime.now().subtract(const Duration(hours: 12)),
              note: 'We are processing the reversal with the beneficiary bank.',
            ),
            RequestEvent(
              status: RequestStatus.resolved,
              at: DateTime.now().subtract(const Duration(hours: 6)),
              note: 'The amount has been reversed to your account.',
            ),
          ],
        ),
      ];
}
