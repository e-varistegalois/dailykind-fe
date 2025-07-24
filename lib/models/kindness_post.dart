class KindnessPost {
  final String id;
  final String challengeId;
  final String userId;
  final String? userProfileImage;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final DateTime createdAt;
  final bool isLiked;

  KindnessPost({
    required this.id,
    required this.challengeId,
    required this.userId,
    this.userProfileImage,
    required this.content,
    this.imageUrl,
    required this.likesCount,
    required this.createdAt,
    this.isLiked = false,
  });

  factory KindnessPost.fromJson(Map<String, dynamic> json) {
    return KindnessPost(
      id: json['id'] ?? '',
      challengeId: json['challengeId'] ?? '',
      userId: json['userId'] ?? '',
      userProfileImage: json['userProfileImage'],
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      likesCount: json['likesCount'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isLiked: json['isLiked'] ?? false,
    );
  }
}
