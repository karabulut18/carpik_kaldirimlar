import 'package:carpik_kaldirimlar/services/auth_service.dart';
import 'package:carpik_kaldirimlar/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  Widget createSubject() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
      ],
      child: const MaterialApp(
        home: LoginView(),
      ),
    );
  }

  group('LoginView Widget Tests', () {
    testWidgets('shows validation errors for empty fields', (tester) async {
      await tester.pumpWidget(createSubject());

      // Tap Login button without entering data
      await tester.tap(find.text('Giriş Yap'));
      await tester.pump(); // Rebuild for validation errors

      expect(find.text('E-posta gerekli'), findsOneWidget);
      expect(find.text('Şifre gerekli'), findsOneWidget);
    });

    testWidgets('does not show error when fields are filled', (tester) async {
      await tester.pumpWidget(createSubject());

      await tester.enterText(find.ancestor(of: find.text('E-posta'), matching: find.byType(TextFormField)), 'test@example.com');
      await tester.enterText(find.ancestor(of: find.text('Şifre'), matching: find.byType(TextFormField)), 'password');

      await tester.tap(find.text('Giriş Yap'));
      await tester.pump();

      expect(find.text('E-posta gerekli'), findsNothing);
      expect(find.text('Şifre gerekli'), findsNothing);
    });
  });
}
