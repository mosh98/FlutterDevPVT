import 'package:dog_prototype/pages/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver{}

class MockFirebaseAuth extends Mock implements FirebaseAuth{}
class MockFirebaseUser extends Mock implements FirebaseUser{}
class MockAuthResult extends Mock implements AuthResult{}
class MockAuthCredentials extends Mock implements AuthCredential{}
class MockEmailAuthProvider extends Mock implements EmailAuthProvider{}

void main(){

  LoginPage loginPage = LoginPage();

  Widget page = MaterialApp(
      home: loginPage
  );

  Finder emailField = find.byKey(Key('Email'));
  Finder passwordField = find.byKey(Key('password'));
  Finder loginButton = find.byKey(Key('signIn'));
  Finder facebookButton = find.byKey(Key('facebook'));
  Finder forgotButton = find.byKey(Key('forgot'));

  group('defaults', () {
    testWidgets('Rendering page', (tester)async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage),findsOneWidget);
    });

    testWidgets('Testing finding all widgets on screen', (WidgetTester tester) async{
      await tester.pumpWidget(page);
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);
      expect(facebookButton, findsOneWidget);
      expect(forgotButton, findsOneWidget);
    });
  });
}