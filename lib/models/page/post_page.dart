import '../post.dart';

class PostPage {
  final List<Post> content;
  final int totalPages;
  final int totalElements;
  final int size;
  final int number; // 当前页（从 0 开始）
  final bool first;
  final bool last;
  final int numberOfElements;
  final bool empty;

  PostPage({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
    required this.numberOfElements,
    required this.empty,
  });

  factory PostPage.fromJson(Map<String, dynamic> json) {
    return PostPage(
      content: (json['content'] as List<dynamic>)
          .map((item) => Post.fromJson(item))
          .toList(),
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      size: json['size'],
      number: json['number'],
      first: json['first'],
      last: json['last'],
      numberOfElements: json['numberOfElements'],
      empty: json['empty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((post) => post.toJson()).toList(),
      'totalPages': totalPages,
      'totalElements': totalElements,
      'size': size,
      'number': number,
      'first': first,
      'last': last,
      'numberOfElements': numberOfElements,
      'empty': empty,
    };
  }
}
