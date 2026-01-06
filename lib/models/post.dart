class Post {
  final String id;
  final String title;
  final String author;
  final String authorId; // Added for moderation
  final DateTime date;
  final String? excerpt;
  final String? imageUrl;
  final String? content;
  final int viewCount;
  final List<String> likes; // User IDs

  Post({
    required this.id,
    required this.title,
    required this.author,
    required this.authorId,
    required this.date,
    this.excerpt,
    this.imageUrl,
    this.content,
    this.viewCount = 0,
    this.likes = const [],
  });

  int get likeCount => likes.length;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'authorId': authorId,
      'date': date.millisecondsSinceEpoch,
      'excerpt': excerpt,
      'content': content,
      'imageUrl': imageUrl,
      'viewCount': viewCount,
      'likes': likes,
    };
  }

  factory Post.fromMap(String id, Map<String, dynamic> map) {
    return Post(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      authorId: map['authorId'] ?? '', // Default to empty if missing
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      excerpt: map['excerpt'],
      content: map['content'],
      imageUrl: map['imageUrl'],
      viewCount: map['viewCount'] ?? 0,
      likes: List<String>.from(map['likes'] ?? []),
    );
  }
}
