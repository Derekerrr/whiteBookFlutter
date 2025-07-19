import '../post_comments.dart';

class CommentPage {
  final List<Comment> content;
  final bool isLast;
  final int totalPages;
  final int totalElements;
  final int pageSize;
  final int pageNumber;

  CommentPage({
    required this.content,
    required this.isLast,
    required this.totalPages,
    required this.totalElements,
    required this.pageSize,
    required this.pageNumber,
  });

  factory CommentPage.fromJson(Map<String, dynamic> json) {
    var list = json['data']['content'] as List;
    List<Comment> contentList = list.map((i) => Comment.fromJson(i)).toList();

    return CommentPage(
      content: contentList,
      isLast: json['data']['last'],
      totalPages: json['data']['totalPages'],
      totalElements: json['data']['totalElements'],
      pageSize: json['data']['size'],
      pageNumber: json['data']['number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((e) => e.toJson()).toList(),
      'isLast': isLast,
      'totalPages': totalPages,
      'totalElements': totalElements,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };
  }
}
