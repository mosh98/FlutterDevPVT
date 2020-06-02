import 'package:dog_prototype/pages/LoginPage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';


void main(){

  /**
   * TESTING WIDGET OF LOGIN_PAGE
   */
  testWidgets('username or password is wrong, does not sign-in AND show helper-text', (WidgetTester tester) async{

    LoginPage page = LoginPage();

    await tester.pumpWidget(page);

    Finder usernameField = find.byKey(Key('username'));
    expect(usernameField, findsOneWidget);

    await tester.enterText(usernameField, 'some_username');
    expect(find.text("some_username"), findsOneWidget);

    Finder passwordField = find.byKey(Key('password'));
    expect(passwordField,findsOneWidget);

    await tester.enterText(passwordField, 'some_password');
    expect(find.text("some_password"), findsOneWidget);

    var button = find.byKey((Key('signIn')));
    expect(button,findsOneWidget);

    //show helper text
    await tester.tap(button);
    await tester.pump();
    expect(find.text('Wrong username or password'),findsOneWidget);
  });

}