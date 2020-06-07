



import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/FindFriends.dart';
import 'package:dog_prototype/pages/profileViewer.dart';
import 'package:dog_prototype/services/HttpProvider.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver{}

class MockHttpProvider extends Mock implements HttpProvider{

  static String fakeUsernameOne = 'fakeuser1';
  static String fakeUserUserIDOne = '1';
  static String fakeUsernameTwo = 'fakeuser2';
  static String fakeUserUserIdTwo = '2';

  final String fakeUserData =
      '[{"username":"$fakeUsernameOne", "userId":"$fakeUserUserIDOne"},{"username":"$fakeUsernameTwo", "userId":"$fakeUserUserIdTwo"}]';

  @override
  Future<String> getUsers(String input) async{
    return fakeUserData;
  }
}

class MockStorageProvider extends Mock implements StorageProvider{

  @override
  getOtherProfileImage(User user) {
    return null;
  }
}

void main(){

  const String fakeUserUserIDOne = '1';
  const String fakeUserUserIdTwo = '2';

  final MockNavigatorObserver mockNavigatorObserver = MockNavigatorObserver();
  final MockHttpProvider mockHttpProvider = MockHttpProvider();
  final MockStorageProvider mockStorageProvider = MockStorageProvider();

  User fakeUser = User();

  final FindFriends findFriends = FindFriends(user: fakeUser,httpProvider: mockHttpProvider,storageProvider: mockStorageProvider,);

  final Finder searchBar = find.byKey(Key('search'));

  final Widget page = MaterialApp(
    home: Scaffold(
      body: findFriends,
    ),
    navigatorObservers: [mockNavigatorObserver],
  );

  testWidgets('Rendering page', (tester)async{
    await tester.pumpWidget(page);
    verify(mockNavigatorObserver.didPush(any, any));
    await tester.pumpAndSettle();
    expect(find.byType(FindFriends), findsOneWidget);
  });

  testWidgets('Finding widgets', (tester)async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    expect(searchBar, findsOneWidget);
  });

  testWidgets('Search actually searches for users and displays them', (tester)async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();

    await tester.runAsync(()async{
      await tester.enterText(searchBar, 'fake');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    });
    await tester.pumpAndSettle();

    Finder listBuilderCardOne = find.byKey(Key('$fakeUserUserIDOne')); //SEE FINDFRIENDS PAGE IMPLEMENTATION
    Finder listBuilderCardTwo = find.byKey(Key('$fakeUserUserIdTwo')); //SEE FINDFRIENDS PAGE IMPLEMENTATION
    expect(listBuilderCardOne, findsOneWidget);
    expect(listBuilderCardTwo, findsOneWidget);
  });

  testWidgets('Find widgets of listbuilder cards', (tester)async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();

    await tester.runAsync(()async{
      await tester.enterText(searchBar, 'fake');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    });
    await tester.pumpAndSettle();

    Finder listBuilderCardOne = find.byKey(Key('$fakeUserUserIDOne')); //SEE FINDFRIENDS PAGE IMPLEMENTATION
    Finder listBuilderCardTwo = find.byKey(Key('$fakeUserUserIdTwo')); //SEE FINDFRIENDS PAGE IMPLEMENTATION
    expect(listBuilderCardOne, findsOneWidget);
    expect(listBuilderCardTwo, findsOneWidget);

    Finder iconImage = find.byKey(Key('image'));
    Finder username = find.byKey(Key('username'));
    Finder chatBoxIcon = find.byKey(Key('chat'));
    Finder profileViewerIcon = find.byKey(Key('profileviewer'));

    expect(iconImage,findsNWidgets(2)); // TWO USERS SHOULD SHOW ON PAGE. LOOK ON HTTPPROVIDER MOCK IMPLEMENTATION
    expect(username,findsNWidgets(2)); // TWO USERS SHOULD SHOW ON PAGE. LOOK ON HTTPPROVIDER MOCK IMPLEMENTATION
    expect(chatBoxIcon,findsNWidgets(2)); // TWO USERS SHOULD SHOW ON PAGE. LOOK ON HTTPPROVIDER MOCK IMPLEMENTATION
    expect(profileViewerIcon,findsNWidgets(2)); // TWO USERS SHOULD SHOW ON PAGE. LOOK ON HTTPPROVIDER MOCK IMPLEMENTATION
  });

  testWidgets('Navigation: Tap on card -> PUSH Profileviewer', (tester)async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();

    await tester.runAsync(()async{
      await tester.enterText(searchBar, 'fake');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    });
    await tester.pumpAndSettle();

    Finder listBuilderCardOne = find.byKey(Key('$fakeUserUserIDOne')); //SEE FINDFRIENDS PAGE IMPLEMENTATION

    await tester.tap(listBuilderCardOne);
    verify(mockNavigatorObserver.didPush(any, any));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileViewer), findsOneWidget);
  });
}