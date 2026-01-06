import 'package:carpik_kaldirimlar/models/comment.dart';
import 'package:carpik_kaldirimlar/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostService extends ChangeNotifier {
  final CollectionReference _postsCollection = FirebaseFirestore.instance.collection('posts');
  List<Post> _posts = [];

  List<Post> get posts => List.unmodifiable(_posts);

  PostService() {
    _postsCollection.orderBy('date', descending: true).snapshots().listen((snapshot) {
      _posts = snapshot.docs.map((doc) {
        return Post.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      notifyListeners();
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

  Future<void> addComment(String postId, String text, String authorName, String authorId) async {
    await _postsCollection.doc(postId).collection('comments').add({
      'text': text,
      'authorName': authorName,
      'authorId': authorId,
      'date': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await _postsCollection.doc(postId).collection('comments').doc(commentId).delete();
  }

  Stream<List<Comment>> getCommentsStream(String postId) {
    return _postsCollection
        .doc(postId)
        .collection('comments')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Comment.fromMap(doc.id, doc.data());
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
