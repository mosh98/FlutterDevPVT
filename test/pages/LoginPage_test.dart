import 'package:dog_prototype/pages/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver{}

class MockFirebaseAuth extends Mock implements FirebaseAuth{}
class MockFirebaseUser extends Mock implements FirebaseUser{}
class MockAuthResult extends Mock implements AuthResult{}
class MockAuthCredentials extends Mock implements AuthCredential{}
class MockEmailAuthProvider extends Mock implements EmailAuthProvider{}

void main(){

  LoginPage widget = LoginPage();

  Widget page = MaterialApp(
      home: widget
  );

  Finder emailField = find.byKey(Key('Email'));
  Finder passwordField = find.byKey(Key('password'));
  Finder loginButton = find.byKey(Key('signIn'));
  Finder facebookButton = find.byKey(Key('facebook'));
  Finder forgotButton = find.byKey(Key('forgot'));

  testWidgets('Testing finding all widgets on screen', (WidgetTester tester) async{

    await tester.pumpWidget(page);
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);
    expect(facebookButton, findsOneWidget);
    expect(forgotButton, findsOneWidget);
  });

  group(
      "Testing error-messages UI LoginPage",
          (){
            testWidgets('Route: Sign-in -> ProfilePage', (WidgetTester tester) async{

        });
      }
  );
}