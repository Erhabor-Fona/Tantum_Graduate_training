import '../entities/support_request.dart';

/// Customer support tickets.
abstract interface class SupportRepository {
  Future<List<SupportRequest>> fetchRequests(String token);
  Future<SupportRequest> fetchRequest(String token, String id);
  Future<SupportRequest> createRequest(
    String token, {
    required String category,
    required String issueType,
    required String description,
    String? transactionReference,
    String? attachmentName,
  });
}
