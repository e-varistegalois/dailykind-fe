class SessionSummary {
  final String sessionId;
  final String displayChat;
  final String createdAt;
  final String personality;

  SessionSummary({
    required this.sessionId,
    required this.displayChat,
    required this.createdAt,
    required this.personality,
  });

  factory SessionSummary.fromJson(Map<String, dynamic> json) {
    return SessionSummary(
      sessionId: json['sessionId'].toString(),
      displayChat: json['displayChat'] ?? 'Belum ada chat',
      createdAt: json['createdAt'] ?? '',
      personality: json['personality'] ?? 'Unknown',
    );
  }
}
