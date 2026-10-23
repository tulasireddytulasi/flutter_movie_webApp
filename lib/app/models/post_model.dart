class PostModel {
  final String id;
  final String name;
  final String handle;
  final String avatarUrl;
  final String timestamp;
  final String content;
  final List<String> imageUrls;
  int replyCount;
  int repostCount;
  int likeCount;
  int viewCount;
  bool isLiked;
  bool isReposted;
  bool isBookmarked;

  PostModel({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.timestamp,
    required this.content,
    required this.imageUrls,
    required this.replyCount,
    required this.repostCount,
    required this.likeCount,
    required this.viewCount,
    this.isLiked = false,
    this.isReposted = false,
    this.isBookmarked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      handle: json['handle'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      timestamp: json['timestamp'] ?? '',
      content: json['content'] ?? '',
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      replyCount: json['replyCount'] ?? 0,
      repostCount: json['repostCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isReposted: json['isReposted'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'handle': handle,
      'avatarUrl': avatarUrl,
      'timestamp': timestamp,
      'content': content,
      'imageUrls': imageUrls,
      'replyCount': replyCount,
      'repostCount': repostCount,
      'likeCount': likeCount,
      'viewCount': viewCount,
      'isLiked': isLiked,
      'isReposted': isReposted,
      'isBookmarked': isBookmarked,
    };
  }
}
