import 'package:easy_chat/models/post_image.dart';

class Post {
  final String id;
  final String? title;
  final List<PostImage> images;
  final String userId;
  final String userNickname;
  final String userAvatar;
  int likeCount;
  bool isLiked;
  int favoriteCount;
  bool isFavorite;
  final String? content;
  int commentCount;
  final DateTime postTime;
  final int viewCount;

  Post({
    required this.id,
    this.title,
    required this.images,
    required this.userId,
    required this.userNickname,
    required this.userAvatar,
    required this.commentCount,
    this.likeCount = 0,
    this.content,
    required this.viewCount,
    required this.postTime,
    required this.isLiked,
    required this.favoriteCount,
    required this.isFavorite,
  });

  Post copyWith({
    String? id,
    String? title,
    List<PostImage>? images,
    String? userId,
    String? userNickname,
    String? userAvatar,
    int? likeCount,
    bool? isLiked,
    int? favoriteCount,
    bool? isFavorite,
    String? content,
    DateTime? postTime,
    int? commentCount,
    int? viewCount
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      images: images ?? this.images,
      userId: userId ?? this.userId,
      userNickname: userNickname ?? this.userNickname,
      userAvatar: userAvatar ?? this.userAvatar,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      isFavorite: isFavorite ?? this.isFavorite,
      content: content ?? this.content,
      postTime: postTime ?? this.postTime,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount
    );
  }
  // From JSON constructor
  factory Post.fromJson(Map<String, dynamic> json) {
    // Parse the images list
    var imagesList = (json['images'] as List)
        .map((item) => PostImage.fromJson(item))
        .toList();

    // Parse the date string into DateTime
    DateTime postTime = DateTime.parse(json['postTime']);

    return Post(
      id: json['id'].toString(),
      title: json['title'],
      images: imagesList,
      userId: json['userId'].toString(),
      userNickname: json['userNickname'] ?? '', // Fallback to empty string if null
      userAvatar: json['userAvatar'] ?? '', // Fallback to empty string if null
      commentCount: json['commentCount'],
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] ?? false, // Assume false if not provided
      favoriteCount: json['favoriteCount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false, // Assume false if not provided
      content: json['content'],
      postTime: postTime,
      viewCount: json['viewCount'] ?? 0,
    );
  }

  // To JSON method (if you want to send the object back to the server)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'images': images.map((image) => image.toJson()).toList(),
      'userId': userId,
      'userNickname': userNickname,
      'userAvatar': userAvatar,
      'likeCount': likeCount,
      'isLiked': isLiked,
      'favoriteCount': favoriteCount,
      'isFavorite': isFavorite,
      'content': content,
      'commentCount': commentCount,
      'postTime': postTime.toIso8601String(),
    };
  }
}

