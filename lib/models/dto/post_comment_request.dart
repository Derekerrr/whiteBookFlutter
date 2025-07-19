class PostCommentRequest {
  final String content; // 必选，1~1000字符
  final String? userId; // 不填
  final String? parentId; // 可选
  final String? repliedCommentId; // 可选
  final String? repliedUserId; // 可选
  final String postId; // 必选

  PostCommentRequest({
    required this.content,
    required this.postId,
    this.userId,
    this.parentId,
    this.repliedCommentId,
    this.repliedUserId,
  });

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic> {
      'content': content,
      'postId': postId,
    };

    // 可选字段只有在非空时才会被添加
    if (userId != null) data['userId'] = userId;
    if (parentId != null) data['parentId'] = parentId;
    if (repliedCommentId != null) data['repliedCommentId'] = repliedCommentId;
    if (repliedUserId != null) data['repliedUserId'] = repliedUserId;

    return data;
  }
}
