class Comment {
  final String id;
  final String postId;
  final String userNickname;
  final String userAvatar;
  final String userId;
  int likeCount;
  bool isLiked;
  final String? parentId;
  late final String content;
  final List<Comment> replies;
  final DateTime createTime;
  final String? repliedCommentId;
  final String? repliedUserId;
  final String? repliedUserNickname;
  late int childPage;
  late bool hasMoreChild;  // 新增的属性
  late int childCount;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.userNickname,
    required this.userAvatar,
    required this.parentId,
    required this.content,
    required this.likeCount,
    required this.isLiked,
    required this.createTime,
    this.repliedUserNickname,
    this.repliedUserId,
    this.repliedCommentId,
    List<Comment>? replies,
    this.childPage = 1,
    this.hasMoreChild = false, // 默认值为 false
    this.childCount = 0,
  }) : replies = replies ?? [];

  // copyFrom 方法：返回一个新的 Comment 对象，修改某些属性
  Comment copyFrom({
    String? id,
    String? postId,
    String? userNickname,
    String? userAvatar,
    String? userId,
    int? likeCount,
    bool? isLiked,
    String? parentId,
    String? content,
    List<Comment>? replies,
    DateTime? createTime,
    String? repliedCommentId,
    String? repliedUserId,
    String? repliedUserNickname,
    int? childPage,
    bool? hasMoreChild,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userNickname: userNickname ?? this.userNickname,
      userAvatar: userAvatar ?? this.userAvatar,
      userId: userId ?? this.userId,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      parentId: parentId ?? this.parentId,
      content: content ?? this.content,
      replies: replies ?? this.replies,
      createTime: createTime ?? this.createTime,
      repliedCommentId: repliedCommentId ?? this.repliedCommentId,
      repliedUserId: repliedUserId ?? this.repliedUserId,
      repliedUserNickname: repliedUserNickname ?? this.repliedUserNickname,
      childPage: childPage ?? this.childPage,
      hasMoreChild: hasMoreChild ?? this.hasMoreChild,
    );
  }

  // 将 JSON 转换为 Comment 对象
  factory Comment.fromJson(Map<String, dynamic> json) {
    var list = json['replies'] as List;
    List<Comment> repliesList = list.map((i) => Comment.fromJson(i)).toList();

    return Comment(
        id: json['id'].toString(),
        userId: json['userId'].toString(),
        postId: json['postId'].toString(),
        userNickname: json['userNickname'],
        userAvatar: json['userAvatar'],
        parentId: json['parentId']?.toString(),
        content: json['content'],
        likeCount: json['likeCount'],
        isLiked: json['liked'],
        createTime: DateTime.parse(json['createTime']),
        repliedCommentId: json['repliedCommentId']?.toString(),
        repliedUserId: json['repliedUserId']?.toString(),
        repliedUserNickname: json['repliedUserNickname'],
        replies: repliesList,
        hasMoreChild: json['hasMoreChild'] ?? false,  // 如果 JSON 中没有该字段，默认为 false
        childPage: 1,
        childCount: json['childCount'] ?? 0
    );
  }

  // 将 Comment 对象转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userNickname': userNickname,
      'userAvatar': userAvatar,
      'parentId': parentId,
      'content': content,
      'likeCount': likeCount,
      'liked': isLiked,
      'createTime': createTime.toIso8601String(),
      'repliedCommentId': repliedCommentId,
      'repliedUserId': repliedUserId,
      'repliedUserNickname': repliedUserNickname,
      'replies': replies.map((e) => e.toJson()).toList(),
      'hasMoreChild': hasMoreChild,  // 新增的字段
      'childPage': childPage
    };
  }
}
