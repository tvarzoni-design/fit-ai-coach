import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fit_ai_coach/core/services/auth_service.dart';
import 'package:fit_ai_coach/core/services/api_service.dart';
import 'package:fit_ai_coach/modules/auth/pages/login_page.dart';

class MockAuthService extends AuthService {
  @override
  Future<bool> login(String email, String password) async => true;

  @override
  Future<bool> signInWithGoogle() async => true;

  @override
  Future<bool> signInWithApple() async => true;
}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthService>.value(
        value: mockAuthService,
        child: const LoginPage(),
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
    });

    testWidgets('has Google and Apple sign-in buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Entrar com Google'), findsOneWidget);
      expect(find.text('Entrar com Apple'), findsOneWidget);
    });

    testWidgets('shows error for empty email field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira seu email'), findsOneWidget);
    });

    testWidgets('shows error for empty password field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@email.com');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
    });

    testWidgets('forgot password link exists', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Esqueci a senha'), findsOneWidget);
    });

    testWidgets('register link exists', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Cadastre-se'), findsOneWidget);
      expect(find.text('Não tem conta? '), findsOneWidget);
    });
  });
}
