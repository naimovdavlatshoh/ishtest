class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorHeadline;
  final String authorAvatar;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final List<String>? hashtags;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorHeadline,
    required this.authorAvatar,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
    this.hashtags,
  });

  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorHeadline,
    String? authorAvatar,
    String? content,
    String? imageUrl,
    String? videoUrl,
    DateTime? timestamp,
    int? likes,
    int? comments,
    int? shares,
    bool? isLiked,
    List<String>? hashtags,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorHeadline: authorHeadline ?? this.authorHeadline,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
      hashtags: hashtags ?? this.hashtags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorHeadline': authorHeadline,
      'authorAvatar': authorAvatar,
      'content': content,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'isLiked': isLiked,
      'hashtags': hashtags,
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorHeadline: json['authorHeadline'] as String,
      authorAvatar: json['authorAvatar'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      hashtags: (json['hashtags'] as List<dynamic>?)?.cast<String>(),
    );
  }
}
