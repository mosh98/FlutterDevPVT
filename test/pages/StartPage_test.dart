import 'package:dog_prototype/pages/LoginPage.dart';
import 'package:dog_prototype/pages/RegisterPage.dart';
import 'package:dog_prototype/pages/StartPage.dart';
import 'package:dog_prototype/pages/mapPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver{}

void main(){

  final mockObserver = MockNavigatorObserver();
  Widget page = MaterialApp(
    home: StartPage(),
    navigatorObservers: [mockObserver],
  );

  Finder loginButton = find.byKey(Key('login'));
  Finder viewMapButton = find.byKey(Key('viewmap'));
  Finder registerButton = find.byKey(Key('register'));

  group('defaults', () {
    testWidgets('Rendering page', (tester)async{
      await tester.pumpWidget(page);
      expect(find.byType(StartPage),findsOneWidget);
    });

    testWidgets('Finding widgets', (tester)async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();
      expect(loginButton, findsOneWidget);
      expect(viewMapButton, findsOneWidget);
      expect(registerButton, findsOneWidget);
    });
  });

  group(
    "Tests of routing on start-page",
      (){

        testWidgets('Route: Loginbutton -> LoginPage', (WidgetTester tester) async{
          await tester.pumpWidget(page);

          await tester.pumpAndSettle();

          await tester.tap(loginButton);
          await tester.pumpAndSettle();

          verify(mockObserver.didPush(any, any));

          expect(find.byType(LoginPage), findsOneWidget);
        });

        testWidgets('Route: viewMapButton -> Map', (WidgetTester tester) async{
          await tester.pumpWidget(page);

          await tester.pumpAndSettle();

          await tester.tap(viewMapButton);
          await tester.pumpAndSettle();

          verify(mockObserver.didPush(any, any));

          expect(find.byType(MapPage), findsOneWidget);
        });

        testWidgets('Route: registerButton -> Register', (WidgetTester tester) async{
          await tester.pumpWidget(page);

          await tester.pumpAndSettle();

          await tester.tap(registerButton);
          await tester.pumpAndSettle();

          verify(mockObserver.didPush(any, any));

          expect(find.byType(RegisterPage), findsOneWidget);
        });
      }
  );
}