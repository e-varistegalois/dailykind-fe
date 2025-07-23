class Challenge {
  final String id;
  final String content;
  final String timestamp;
  final bool isActive;

  Challenge({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isActive,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  // Helper method untuk parsing content markdown
  String get cleanContent {
    return content
        .replaceAll('**', '') // Remove bold markdown
        .replaceAll('"', '"')  // Clean quotes
        .trim();
  }
}
