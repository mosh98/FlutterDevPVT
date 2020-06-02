
import 'package:dog_prototype/pages/RegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){
  /**
   * TESTING WIDGET OF LOGIN_PAGE
   */

  RegisterPage page = RegisterPage();
  Finder emailField = find.byKey(Key('email'));
  Finder passwordField = find.byKey(Key('password'));
  Finder passwordRepeatField = find.byKey(Key('repeatPassword'));
  Finder usernameField = find.byKey(Key('username'));
  Finder dateOfBirth = find.byKey(Key('dateOfBirth'));
  Finder gender = find.byKey(Key('gender'));
  Finder signUpButton = find.byKey((Key('signUp')));

  testWidgets('Finding widgets', (WidgetTester tester) async{

    await tester.pumpWidget(page);

    expect(emailField, findsOneWidget);

    expect(passwordField, findsOneWidget);

    expect(passwordRepeatField, findsOneWidget);

    expect(usernameField, findsOneWidget);

    expect(dateOfBirth, findsOneWidget);

    expect(gender, findsOneWidget);

    expect(signUpButton,findsOneWidget);
  });

  testWidgets('Testing textfields response to text', (WidgetTester tester) async{

    await tester.pumpWidget(page);

    await tester.enterText(emailField, 'some_email');
    expect(find.text("some_email"), findsOneWidget);

    await tester.enterText(emailField, 'some_password');
    expect(find.text("some_password"), findsOneWidget);

    await tester.enterText(passwordRepeatField, 'some_password1');
    expect(find.text("some_password1"), findsOneWidget);
    
    await tester.enterText(usernameField, 'some_username');
    expect(find.text("some_username"), findsOneWidget);
  });

  testWidgets('Testing hint-text of empty email', (WidgetTester tester) async{

    final errorMessage = find.text('Please enter a valid e-mail adress');

    page = RegisterPage();

    await tester.pumpWidget(page);


    await tester.enterText(passwordField, 'some_password');
    await tester.enterText(passwordRepeatField, 'some_password');
    expect(find.text("some_password"), findsNWidgets(2));

    await tester.enterText(usernameField, 'some_username');
    expect(find.text("some_username"), findsOneWidget);

    await tester.tap(signUpButton);
    await tester.pump(const Duration(milliseconds: 100));
    expect(errorMessage,findsOneWidget);
  });

  testWidgets('Testing hint-text of empty password', (WidgetTester tester) async{

    final errorMessage = find.text('Please enter a password');

    page = RegisterPage();

    await tester.pumpWidget(page);

    await tester.enterText(passwordRepeatField, 'some_password');
    expect(find.text("some_password"), findsOneWidget);

    await tester.enterText(usernameField, 'some_username');
    expect(find.text("some_username"), findsOneWidget);

    await tester.tap(signUpButton);
    await tester.pump(const Duration(milliseconds: 100));
    expect(errorMessage,findsOneWidget);
  });

  testWidgets('Testing hint-text of password with only spaces', (WidgetTester tester) async{

    final errorMessage = find.text('Please enter a password');

    page = RegisterPage();

    await tester.pumpWidget(page);

    Finder emailField = find.byKey(Key('email'));
    expect(emailField, findsOneWidget);

    Finder passwordField = find.byKey(Key('password'));
    await tester.enterText(passwordField, '        ');
    expect(passwordField, findsOneWidget);
    Finder passwordRepeatField = find.byKey(Key('repeatPassword'));
    expect(passwordRepeatField, findsOneWidget);
    await tester.enterText(passwordRepeatField, 'some_password');
    expect(find.text("some_password"), findsOneWidget);

    Finder usernameField = find.byKey(Key('username'));
    expect(usernameField, findsOneWidget);
    await tester.enterText(usernameField, 'some_username');
    expect(find.text("some_username"), findsOneWidget);

    await tester.tap(signUpButton);
    await tester.pump(const Duration(milliseconds: 100));
    expect(errorMessage,findsOneWidget);
  });

  testWidgets('Testing hint-text of password < 6 characters', (WidgetTester tester) async{

    final errorMessage = find.text('Password need to be at least 6 characters long');

    page = RegisterPage();

    await tester.pumpWidget(page);

    await tester.enterText(passwordField, '12345');
    expect(find.text("12345"), findsOneWidget);

    await tester.enterText(passwordRepeatField, 'some_password');
    expect(find.text("some_password"), findsOneWidget);

    await tester.enterText(usernameField, 'some_username');
    expect(find.text("some_username"), findsOneWidget);

    await tester.tap(signUpButton);
    await tester.pump(const Duration(milliseconds: 100));
    expect(errorMessage,findsOneWidget);
  });

  testWidgets('Testing hint-text of password > 15 characters', (WidgetTester tester) async{

    final errorMessage = find.text('Password need to be less than 16 characters long');

    page = RegisterPage();

    await tester.pumpWidget(page);

    await tester.enterText(passwordField, '123456789123456789');
    expect(find.text("123456789123456789"), findsOneWidget);

    await tester.enterText(passwordRepeatField, 'some_password');
    expect(find.text("some_password"), findsOneWidget);

    await tester.enterText(usernameField, 'some_username');
    expect(find.text("some_username"), findsOneWidget);

    await tester.tap(signUpButton);
    await tester.pump(const Duration(milliseconds: 100));
    expect(errorMessage,findsOneWidget);
  });

  testWidgets('Testing hint-text of passwords not matching', (WidgetTester tester) async{

    final errorMessage = find.text('Passwords do not match.');

    page = RegisterPage();

    await tester.pumpWidget(page);

    await tester.enterText(passwordField, '123456789123456789');
    expect(find.text("123456789123456789"), findsOneWidget);

    await tester.enterText(passwordRepeatField, 'some_password');
    expect(find.text("some_password"), findsOneWidget);

    await tester.enterText(usernameField, 'some_username');
    expect(find.text("some_username"), findsOneWidget);

    await tester.tap(signUpButton);
    await tester.pump(const Duration(milliseconds: 100));
    expect(errorMessage,findsOneWidget);
  });

  testWidgets('Testing hint-text of empty username or username of only spaces', (WidgetTester tester) async{

    final errorMessage = find.text('Please enter a username');

    page = RegisterPage();

    await tester.pumpWidget(page);

    await tester.tap(signUpButton);
    await tester.pump(const Duration(milliseconds: 100));
    expect(errorMessage,findsOneWidget);

    await tester.enterText(usernameField, '    ');
    await tester.tap(signUpButton);
    await tester.pump(const Duration(milliseconds: 100));
    expect(errorMessage,findsOneWidget);
  });

  testWidgets('Testing hint-text of username > 29 characters', (WidgetTester tester) async{

    final errorMessage = find.text('Username need to be less than 30 characters long');

    page = RegisterPage();

    await tester.pumpWidget(page);

    await tester.enterText(usernameField, '123456789123456789123456789122345');
    expect(find.text("123456789123456789123456789122345"), findsOneWidget);

    await tester.tap(signUpButton);
    await tester.pump(const Duration(milliseconds: 100));
    expect(errorMessage,findsOneWidget);

    await tester.enterText(usernameField, '                           12345679');
    expect(find.text('                           12345679'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    expect(errorMessage,findsOneWidget);
  });
}