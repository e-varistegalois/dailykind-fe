class ChatSession {
  final String id;
  final String personality;
  final String lastMessage;

  ChatSession({required this.id, required this.personality, required this.lastMessage});

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      personality: json['personality'],
      lastMessage: json['lastMessage'] ?? '',
    );
  }
}