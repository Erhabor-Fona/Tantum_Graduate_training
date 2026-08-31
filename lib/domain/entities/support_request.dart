/// Where a support ticket sits in its lifecycle.
enum RequestStatus {
  received('Received'),
  underReview('Under Review'),
  inProgress('In Progress'),
  resolved('Resolved');

  final String label;
  const RequestStatus(this.label);

  static RequestStatus parse(String? raw) => RequestStatus.values.firstWhere(
        (s) => s.name == raw,
        orElse: () => RequestStatus.received,
      );
}

/// One step on the Request Status tracker / Activity Timeline.
class RequestEvent {
  final RequestStatus status;
  final DateTime? at;
  final String? note;
  const RequestEvent({required this.status, this.at, this.note});

  bool get isComplete => at != null;
}

/// A customer support ticket.
class SupportRequest {
  final String id;
  final String category;
  final String issueType;
  final String description;
  final String? transactionReference;
  final String? attachmentName;
  final double? amount;
  final RequestStatus status;
  final DateTime createdAt;
  final List<RequestEvent> timeline;
  final String? resolutionNote;
  final DateTime? resolvedAt;

  const SupportRequest({
    required this.id,
    required this.category,
    required this.issueType,
    required this.description,
    required this.createdAt,
    this.transactionReference,
    this.attachmentName,
    this.amount,
    this.status = RequestStatus.received,
    this.timeline = const [],
    this.resolutionNote,
    this.resolvedAt,
  });

  bool get isResolved => status == RequestStatus.resolved;
}
