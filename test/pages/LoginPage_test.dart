import 'package:dog_prototype/pages/LoginPage.dart';
import 'package:dog_prototype/pages/ProfilePage.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver{}

class MockAuthService extends Mock implements AuthService{}

void main(){

  group(
      "Tests of routing on login-page",
          (){
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

          await tester.tap(signInButton);
          await tester.pumpAndSettle();

          verify(mockObserver.didPush(any, any));

          expect(find.byType(ProfilePage), findsOneWidget);
        });
      }
  );
}