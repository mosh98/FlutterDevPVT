import 'package:dog_prototype/dialogs/ChangePasswordDialog.dart';
import 'package:dog_prototype/dialogs/DeleteAccountDialog.dart';
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/SettingsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver{}

void main(){
  final mockObserver = MockNavigatorObserver();

  const String DEFAULT_USER_ID = '1';
  const String DEFAULT_USERNAME = 'username';
  const String DEFAULT_DATE_OF_BIRTH = '2020-01-01';
  const String DEFAULT_GENDER = 'MALE';
  const String DEFAULT_DESC = 'desc';
  const String DEFAULT_CREATED_DATE = '2020-01-01';
  const String DEFAULT_PHOTO_URL = 'URL';
  const String DEFAULT_BUCKET = 'BUCKET';
  final User fakeUser = User(userId: DEFAULT_USER_ID, username: DEFAULT_USERNAME, dateOfBirth: DEFAULT_DATE_OF_BIRTH, gender: DEFAULT_GENDER, desc: DEFAULT_DESC, createdDate: DEFAULT_CREATED_DATE, dogs: [Dog(uuid: '1'),Dog(uuid: '2')],photoUrl: DEFAULT_PHOTO_URL, bucket: DEFAULT_BUCKET, friends: [User(userId: '5'),User(userId: '6')]);

  final SettingsPage settingsPage = SettingsPage(user: fakeUser, isTest: true,);
  final Widget page = MaterialApp(
    home: settingsPage,
    navigatorObservers: [mockObserver],
  );

  Finder usernameText = find.byKey(Key('username'));
  Finder emailText = find.byKey(Key('email'));
  Finder dateOfBirthText = find.byKey(Key('dateofbirth'));
  Finder genderText = find.byKey(Key('gender'));
  Finder changePasswordButton = find.byKey(Key('changepassword'));
  Finder deleteAccountButton = find.byKey(Key('deleteaccount'));
  Finder logOutButton = find.byKey(Key('logout'));

  testWidgets('Finding widgets', (WidgetTester tester) async{

    await tester.pumpWidget(page);

    await tester.pumpAndSettle();

    expect(usernameText, findsOneWidget);
    expect(emailText, findsOneWidget);
    expect(dateOfBirthText, findsOneWidget);
    expect(genderText, findsOneWidget);
    expect(changePasswordButton, findsOneWidget);
    expect(deleteAccountButton, findsOneWidget);
    expect(logOutButton, findsOneWidget);

  });

  testWidgets('Widgets display actual user data', (WidgetTester tester) async{

    String defaultEmailNullFirebaseUser = 'No email';

    await tester.pumpWidget(page);

    await tester.pumpAndSettle();

    expect(find.text(DEFAULT_USERNAME), findsOneWidget);
    expect(find.text(defaultEmailNullFirebaseUser), findsOneWidget);
    expect(find.text(DEFAULT_DATE_OF_BIRTH), findsOneWidget);
    expect(find.text(DEFAULT_GENDER), findsOneWidget);
  });

  testWidgets('Pressing log out button shows alert dialog - Log out', (WidgetTester tester) async{

    await tester.pumpWidget(page);

    await tester.tap(logOutButton);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    expect(find.text('Are you sure you want to log out?'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
  });

  testWidgets('Pressing log out button -NO- returns to page - Log out', (WidgetTester tester) async{

    await tester.pumpWidget(page);

    await tester.tap(logOutButton);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    Finder noButton = find.byKey(Key('logoutno'));
    await tester.tap(noButton);
    await tester.pumpAndSettle();

    verify(mockObserver.didPop(any, any));

    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets('Pressing log out button -NO- returns to page - Log out', (WidgetTester tester) async{

    await tester.pumpWidget(page);

    await tester.tap(logOutButton);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    Finder noButton = find.byKey(Key('logoutno'));
    await tester.tap(noButton);
    await tester.pumpAndSettle();

    verify(mockObserver.didPop(any, any));

    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets('Pressing log out button -YES- pops dialog and settingspage - Log out', (WidgetTester tester) async{

    await tester.pumpWidget(page);

    await tester.tap(logOutButton);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    Finder noButton = find.byKey(Key('logoutyes'));
    await tester.tap(noButton);
    await tester.pumpAndSettle();

    verify(mockObserver.didPop(any, any));
  });

  testWidgets('Pressing delete account button shows delete account dialog - Log out', (WidgetTester tester) async{

    await tester.pumpWidget(page);

    await tester.tap(deleteAccountButton);
    await tester.pumpAndSettle();
    expect(find.byType(DeleteAccountDialog), findsOneWidget);

    expect(find.text('Are you sure that you want to delete your profile? This is not reversible'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
  });

  testWidgets('Pressing delete account button -NO- pops dialog - Delete account', (WidgetTester tester) async{

    await tester.pumpWidget(page);

    await tester.tap(deleteAccountButton);
    await tester.pumpAndSettle();
    expect(find.byType(DeleteAccountDialog), findsOneWidget);

    Finder noButton = find.byKey(Key('nobutton'));
    await tester.tap(noButton);
    await tester.pumpAndSettle();

    verify(mockObserver.didPop(any, any));
    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets('Pressing change password button shows change password dialog - Change password', (WidgetTester tester) async{

    await tester.pumpWidget(page);

    await tester.tap(changePasswordButton);
    await tester.pumpAndSettle();
    expect(find.byType(ChangePasswordDialog), findsOneWidget);

    expect(find.text('Enter your current password:'), findsOneWidget);
    expect(find.text('Enter'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });
}