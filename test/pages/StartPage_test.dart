import 'package:dog_prototype/pages/LoginPage.dart';
import 'package:dog_prototype/pages/RegisterPage.dart';
import 'package:dog_prototype/pages/StartPage.dart';
import 'package:dog_prototype/pages/mapPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver{}

void main(){

  group(
    "Tests of routing on start-page",
      (){
        final mockObserver = MockNavigatorObserver();

        testWidgets('Route: Loginbutton -> LoginPage', (WidgetTester tester) async{
          await tester.pumpWidget(
              MaterialApp(
                home: StartPage(),
                navigatorObservers: [mockObserver],
              )
          );

          await tester.pumpAndSettle();

          Finder loginButton = find.byKey(Key('login'));
          expect(loginButton, findsOneWidget);

          await tester.tap(loginButton);
          await tester.pumpAndSettle();

          verify(mockObserver.didPush(any, any));

          expect(find.byType(LoginPage), findsOneWidget);
        });

        testWidgets('Route: viewMapButton -> Map', (WidgetTester tester) async{
          await tester.pumpWidget(
              MaterialApp(
                home: StartPage(),
                navigatorObservers: [mockObserver],
              )
          );

          await tester.pumpAndSettle();

          Finder viewMapButton = find.byKey(Key('viewmap'));
          expect(viewMapButton, findsOneWidget);

          await tester.tap(viewMapButton);
          await tester.pumpAndSettle();

          verify(mockObserver.didPush(any, any));

          expect(find.byType(MapPage), findsOneWidget);
        });

        testWidgets('Route: registerButton -> Register', (WidgetTester tester) async{
          await tester.pumpWidget(
              MaterialApp(
                home: StartPage(),
                navigatorObservers: [mockObserver],
              )
          );

          await tester.pumpAndSettle();

          Finder registerButton = find.byKey(Key('register'));
          expect(registerButton, findsOneWidget);

          await tester.tap(registerButton);
          await tester.pumpAndSettle();

          verify(mockObserver.didPush(any, any));

          expect(find.byType(RegisterPage), findsOneWidget);
        });
      }
  );
}