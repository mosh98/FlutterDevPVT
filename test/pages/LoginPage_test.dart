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

  group(
      "Tests of routing on login-page",
          (){
            MockFirebaseAuth _auth = MockFirebaseAuth();
            BehaviorSubject<MockFirebaseUser> _user = BehaviorSubject<MockFirebaseUser>();
            when(_auth.onAuthStateChanged).thenAnswer((_){
              return _user;
            });

            when(_auth.signInWithEmailAndPassword(email: "email", password: "password")).
            thenAnswer((_)async{
              _user.add(MockFirebaseUser());
              return MockAuthResult();
            });

            final mockObserver = MockNavigatorObserver();

            testWidgets('Route: Sign-in -> ProfilePage', (WidgetTester tester) async{
              await tester.pumpWidget(
                  MaterialApp(
                    home: LoginPage(),
                    navigatorObservers: [mockObserver],
                  )
              );

              await tester.pumpAndSettle();

              Finder signInButton = find.byKey(Key('signIn'));
              expect(signInButton, findsOneWidget);

              Finder emailField = find.byKey(Key('Email'));
              expect(emailField, findsOneWidget);

              Finder passwordField = find.byKey(Key('password'));
              expect(passwordField, findsOneWidget);

        });
      }
  );
}