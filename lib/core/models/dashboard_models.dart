class BlogArticleData {
  const BlogArticleData({
    required this.title,
    required this.publishedInfo,
    required this.summary,
    required this.body,
    this.imageUrl,
  });

  final String title;
  final String publishedInfo;
  final String summary;
  final List<String> body;
  final String? imageUrl;

  factory BlogArticleData.fromJson(Map<String, dynamic> json) {
    final dynamic bodyRaw =
        json['body'] ?? json['content'] ?? json['paragraphs'];
    final List<String> paragraphs = bodyRaw is List
        ? bodyRaw.map((dynamic item) => item.toString()).toList()
        : <String>[];

    return BlogArticleData(
      title: (json['title'] ?? '').toString(),
      publishedInfo: (json['publishedInfo'] ?? json['published_at'] ?? '')
          .toString(),
      summary: (json['summary'] ?? json['description'] ?? '').toString(),
      body: paragraphs,
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '').toString().isEmpty
          ? null
          : (json['imageUrl'] ?? json['image_url']).toString(),
    );
  }
}

class FollowMemberData {
  const FollowMemberData({
    required this.name,
    required this.glucoseText,
    required this.level,
    required this.isDanger,
  });

  final String name;
  final String glucoseText;
  final String level;
  final bool isDanger;

  factory FollowMemberData.fromJson(Map<String, dynamic> json) {
    final String level = (json['level'] ?? json['status'] ?? 'Bình thường')
        .toString();
    return FollowMemberData(
      name: (json['name'] ?? '').toString(),
      glucoseText: (json['glucoseText'] ?? json['glucose'] ?? '').toString(),
      level: level,
      isDanger: level.toLowerCase() == 'nguy hiểm',
    );
  }
}

class UserProfileData {
  const UserProfileData({
    required this.id,
    required this.phoneNumber,
    required this.role,
    required this.fullName,
    this.email,
    this.avatarUrl,
    this.status,
  });

  final String id;
  final String phoneNumber;
  final String role;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final String? status;

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      id: (json['id'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString().isEmpty
          ? null
          : (json['email']).toString(),
      avatarUrl: (json['avatarUrl'] ?? '').toString().isEmpty
          ? null
          : (json['avatarUrl']).toString(),
      status: (json['status'] ?? '').toString().isEmpty
          ? null
          : (json['status']).toString(),
    );
  }
}
