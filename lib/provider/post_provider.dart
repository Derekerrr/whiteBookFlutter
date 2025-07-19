import 'package:flutter/material.dart';
import '../models/post.dart';

class PostProvider extends ChangeNotifier {
  final List<Post> _posts = [];

  List<Post> get posts => _posts;

  void setPosts(List<Post> posts) {
    _posts.clear();
    _posts.addAll(posts);
    notifyListeners();
  }

  void addPosts(List<Post> posts) {
    _posts.addAll(posts);
    notifyListeners();
  }

  void updatePost(Post updatedPost) {
    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }

  void clear() {
    _posts.clear();
    notifyListeners();
  }
}
