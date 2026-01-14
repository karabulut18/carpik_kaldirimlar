import 'package:carpik_kaldirimlar/models/comment.dart';
import 'package:carpik_kaldirimlar/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostService extends ChangeNotifier {
  final CollectionReference _postsCollection = FirebaseFirestore.instance.collection('posts');
  List<Post> _posts = [];

  List<Post> get posts => List.unmodifiable(_posts);

  List<Post> getPostsByCategory(String category) {
    if (category == 'Genel') return posts;
    return _posts.where((p) => p.category == category).toList();
  }

  List<Post> getPostsByTag(String tag) {
    return _posts.where((p) => p.tags.contains(tag)).toList();
  }

  List<Post> get featuredPosts {
    return _posts.where((p) => p.isFeatured).toList();
  }

  PostService() {
    _postsCollection.orderBy('date', descending: true).snapshots().listen((snapshot) {
      _posts = snapshot.docs.map((doc) {
        return Post.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error listening to posts: $error');
    });
  }

  Future<void> addPost(Post post) async {
    await _postsCollection.add(post.toMap());
  }

  Future<void> deletePost(String id) async {
    await _postsCollection.doc(id).delete();
  }

  Future<void> updatePost(Post post) async {
     await _postsCollection.doc(post.id).update(post.toMap());
  }

  Future<void> incrementViewCount(String postId) async {
    await _postsCollection.doc(postId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  Future<void> toggleLike(String postId, String userId) async {
    final docRef = _postsCollection.doc(postId);
    final doc = await docRef.get();
    
    if (doc.exists) {
      final post = Post.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      final likes = List<String>.from(post.likes);
      
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }
      
      await docRef.update({'likes': likes});
    }
  }

  // Top-level comments collection
  final CollectionReference _commentsCollection = FirebaseFirestore.instance.collection('comments');

  Future<void> addComment(String postId, String text, String authorName, String authorId, {String? replyToId, String? replyToUserName, int depth = 0}) async {
    await _commentsCollection.add({
      'postId': postId,
      'text': text,
      'authorName': authorName,
      'authorId': authorId,
      'date': FieldValue.serverTimestamp(),
      'likes': [],
      'replyToId': replyToId,
      'replyToUserName': replyToUserName,
      'depth': depth,
    });
  }

  Future<void> toggleCommentLike(String commentId, String userId) async {
    final docRef = _commentsCollection.doc(commentId);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      await docRef.update({'likes': likes});
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    // postId parameter kept for compatibility, but not strictly needed for deletion by ID
    await _commentsCollection.doc(commentId).delete();
  }

  Stream<List<Comment>> getCommentsStream(String postId) {
    return _commentsCollection
        .where('postId', isEqualTo: postId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Comment.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<Comment>> getUserComments(String userId) {
    return _commentsCollection
        .where('authorId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Comment.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  
  Post? getPost(String id) {
    try {
      return _posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
