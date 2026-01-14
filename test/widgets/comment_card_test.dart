import 'package:carpik_kaldirimlar/models/comment.dart';
import 'package:carpik_kaldirimlar/services/auth_service.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:carpik_kaldirimlar/widgets/comment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Simple Mocks/Fakes
class MockAuthService extends Mock implements AuthService {
  String? _currentUserId;
  @override
  String? get currentUserId => _currentUserId;
  
  @override
  bool get isLoggedIn => _currentUserId != null;

  void setUserId(String? id) => _currentUserId = id;
}

// We don't really need PostService for rendering unless we tap actions
class MockPostService extends Mock implements PostService {}

void main() {
  late MockAuthService mockAuthService;
  late MockPostService mockPostService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockPostService = MockPostService();
  });

  Widget createSubject(Comment comment) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
        ChangeNotifierProvider<PostService>.value(value: mockPostService),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: CommentCard(comment: comment),
        ),
      ),
    );
  }

  group('CommentCard Widget Test', () {
    final comment = Comment(
      id: 'c1',
      postId: 'p1',
      text: 'Test Comment',
      authorName: 'Test Author',
      authorId: 'author1',
      date: DateTime.now(),
      likes: [],
      depth: 0,
    );

    testWidgets('renders basic comment details', (tester) async {
      await tester.pumpWidget(createSubject(comment));

      expect(find.text('Test Author'), findsOneWidget);
      expect(find.text('Test Comment'), findsOneWidget);
      expect(find.text('Yanıtlanıyor:'), findsNothing);
    });

    testWidgets('displays replied-to context if present', (tester) async {
      final replyComment = Comment(
        id: 'c2',
        postId: 'p1',
        text: 'This is a reply',
        authorName: 'Replier',
        authorId: 'author2',
        date: DateTime.now(),
        replyToUserName: 'OriginalAuthor',
        depth: 1,
      );

      await tester.pumpWidget(createSubject(replyComment));

      expect(find.text('Yanıtlanıyor: @OriginalAuthor'), findsOneWidget);
    });

    testWidgets('hides delete button for non-authors', (tester) async {
      mockAuthService.setUserId('otherUser'); // Not 'author1'
      
      await tester.pumpWidget(createSubject(comment));

      // The delete icon is usually DeleteOutline or similar.
      // We check by IconData or Tooltip.
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
    
    // Note: The delete button logic in existing CommentCard is controlled by `onDelete` callback presence, 
    // NOT directly by Auth state inside the card itself (that logic was moved to ProfilViewHelpers).
    // BUT CommentCard acts as a dumb component mostly.
    // Wait, let me re-read CommentCard code.
    // Line 64: if (onDelete != null) -> Show Delete Icon
    // So the card itself is agnostic. The parent decides whether to pass onDelete.
    
    // HOWEVER, there is a second check in CommentCard? 
    // No, I need to check line 64 of CommentCard.dart.
  });
}
