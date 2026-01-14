import 'package:carpik_kaldirimlar/models/post.dart';
import 'package:carpik_kaldirimlar/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createSubject(Post post, VoidCallback onTap) {
    return MaterialApp(
      home: Scaffold(
        body: PostCard(post: post, onTap: onTap),
      ),
    );
  }

  group('PostCard Widget Tests', () {
    final post = Post(
      id: '1',
      title: 'Amazing Flutter',
      author: 'Saka',
      authorId: 'user1',
      date: DateTime(2025, 1, 1),
      likes: ['u1', 'u2'],
      viewCount: 100,
      category: 'Tech',
      tags: ['mobile', 'web'],
      excerpt: 'Flutter is great!',
      isFeatured: false,
    );

    testWidgets('renders basic details correctly', (tester) async {
      await tester.pumpWidget(createSubject(post, () {}));

      expect(find.text('Amazing Flutter'), findsOneWidget);
      expect(find.text('Saka'), findsOneWidget);
      expect(find.text('Tech'), findsOneWidget);
      expect(find.text('#mobile'), findsOneWidget);
      expect(find.text('100'), findsOneWidget); // View count
      expect(find.text('2'), findsOneWidget);   // Like count
    });

    testWidgets('triggers onTap callback when clicked', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(createSubject(post, () {
        tapped = true;
      }));

      // Tap "Devamını oku" button
      await tester.tap(find.text('Devamını oku →'));
      expect(tapped, true);
    });
    
     testWidgets('triggers onTap when card body is clicked', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(createSubject(post, () {
        tapped = true;
      }));

      // Tap the title area (Card InkWell)
      await tester.tap(find.text('Amazing Flutter'));
      expect(tapped, true);
    });
  });
}
