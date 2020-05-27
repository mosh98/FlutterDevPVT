import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dog_prototype/pages/OldPagesSavedIncaseProblem/LoginPage.dart';

void main(){

  group('Testing username validator and password validator', (){
    //USERNAME EMPTY
    test('Empty username returns error string', (){
      var result = UserNameValidator.validate('');
      expect(result, 'Username cant be empty');
    });

    //USERNAME NOT EMPTY
    test('non-empty username returns null', (){
      var result = UserNameValidator.validate('username');
      expect(result, null);
    });

    //USERNAME ONLY SPACES
    test('Username only spaces returns error string', (){
      var result = UserNameValidator.validate(' ');
      expect(result, 'Username cant be empty');
    });

    //PASSWORD EMPTY
    test('Empty password returns error string', (){
      var result = PasswordValidator.validate('');
      expect(result, 'Password cant be empty');
    });

    //PASSWORD ONLY SPACES
    test('Password only spaces returns error string', (){
      var result = PasswordValidator.validate(' ');
      expect(result, 'Password cant be empty');
    });

    //PASSWORD NOT EMPTY
    test('non-empty password returns null', (){
      var result = PasswordValidator.validate('password');
      expect(result, null);
    });
  });

  /**
   * TESTING WIDGET OF LOGIN_PAGE
   *
   * Source: https://www.youtube.com/watch?v=75i5VmTI6A0 //TODO: DELETE LINE
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