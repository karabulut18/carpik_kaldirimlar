import 'package:carpik_kaldirimlar/models/post.dart';
import 'package:carpik_kaldirimlar/services/auth_service.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:carpik_kaldirimlar/views/create_post_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockAuthService extends Mock implements AuthService {
  String? _currentUserId = 'user1';
  String? _currentUserName = 'Test User';
  bool _isAdmin = false;

  @override
  String? get currentUserId => _currentUserId;
  @override
  String? get currentUserName => _currentUserName;
  @override
  bool get isAdmin => _isAdmin;
  
  @override
  bool get isLoggedIn => _currentUserId != null;
}

class MockPostService extends Mock implements PostService {
  @override
  Post? getPost(String id) => null; // Simulate new post
}

void main() {
  late MockAuthService mockAuthService;
  late MockPostService mockPostService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockPostService = MockPostService();
  });

  Widget createSubject() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
        ChangeNotifierProvider<PostService>.value(value: mockPostService),
      ],
      child: const MaterialApp(
        home: CreatePostView(), // No GoRouter needed if we don't navigate
      ),
    );
  }

  group('CreatePostView Validation Tests', () {
    setUp(() {
       // Increase surface size to fit the form
       // Note: In newer Flutter versions, use tester.view.physicalSize
       // We can do it inside testWidgets, but let's see.
    });

    testWidgets('TextFields have correct maxLength constraints', (tester) async {
       // Set screen size
       tester.view.physicalSize = const Size(800, 2000);
       tester.view.devicePixelRatio = 1.0;
       addTearDown(tester.view.resetPhysicalSize);
       addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createSubject());
      
      // ... (rest of the test)

      // Verify Title Field
      final titleFinder = find.descendant(
        of: find.widgetWithText(TextFormField, 'Başlık'),
        matching: find.byType(TextField),
      );
      expect(titleFinder, findsOneWidget);
      final titleField = tester.widget<TextField>(titleFinder);
      expect(titleField.maxLength, 100);

      // Verify Excerpt Field
      final excerptFinder = find.descendant(
        of: find.widgetWithText(TextFormField, 'Özet (Opsiyonel)'),
        matching: find.byType(TextField),
      );
      expect(excerptFinder, findsOneWidget);
      final excerptField = tester.widget<TextField>(excerptFinder);
      expect(excerptField.maxLength, 500);

      // Verify Content Field
      final contentFinder = find.descendant(
        of: find.widgetWithText(TextFormField, 'İçerik'),
        matching: find.byType(TextField),
      );
      expect(contentFinder, findsOneWidget);
      final contentField = tester.widget<TextField>(contentFinder);
      expect(contentField.maxLength, 20000);
      
      // Verify Image URL Field
      final imageFinder = find.descendant(
        of: find.widgetWithText(TextFormField, 'Kapak Görseli URL (Opsiyonel)'),
        matching: find.byType(TextField),
      );
      expect(imageFinder, findsOneWidget);
      final imageField = tester.widget<TextField>(imageFinder);
      expect(imageField.maxLength, 500);
    });

    testWidgets('Tags field shows error when more than 20 tags entered', (tester) async {
       tester.view.physicalSize = const Size(800, 2000);
       tester.view.devicePixelRatio = 1.0;
       addTearDown(tester.view.resetPhysicalSize);
       addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createSubject());

      // Find Tags field
      final tagsFinder = find.widgetWithText(TextFormField, 'Etiketler (virgülle ayırın)');
      expect(tagsFinder, findsOneWidget);

      // Enter 21 tags
      String manyTags = List.generate(21, (index) => 'tag$index').join(',');
      await tester.enterText(tagsFinder, manyTags);
      
      // Tap Publish to trigger validation
      final publishButton = find.text('Yayınla');
      expect(publishButton, findsOneWidget);
      
      await tester.ensureVisible(publishButton);
      await tester.pumpAndSettle(); // Animation for scroll

      await tester.tap(publishButton);
      await tester.pumpAndSettle(); // Rebuild for validation error
      
      // Check for error text
      expect(find.text('En fazla 20 etiket ekleyebilirsiniz.'), findsOneWidget);
    });

    testWidgets('Content field requires input', (tester) async {
       tester.view.physicalSize = const Size(800, 2000);
       tester.view.devicePixelRatio = 1.0;
       addTearDown(tester.view.resetPhysicalSize);
       addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createSubject());

      // Leave content empty
      // Tap Publish
      final publishButton = find.text('Yayınla');
      await tester.ensureVisible(publishButton);
      await tester.pumpAndSettle();
      
      await tester.tap(publishButton);
      await tester.pumpAndSettle(); // Rebuild validation

      // Check for error on Title (since it's also required)
      expect(find.text('Başlık gerekli'), findsOneWidget);
      
      // Check for error on Content
      expect(find.text('İçerik gerekli'), findsOneWidget);
    });
  });
}
