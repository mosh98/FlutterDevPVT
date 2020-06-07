import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/FindFriends.dart';
import 'package:dog_prototype/pages/MessengerHandler.dart';
import 'package:dog_prototype/pages/profileViewer.dart';
import 'package:dog_prototype/services/HttpProvider.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver{}

class MockHttpProvider extends Mock implements HttpProvider{

  static String fakeUsernameOne = 'fakeuser1';
  static String fakeUserUserIDOne = '5';
  static String fakeUsernameTwo = 'fakeuser2';
  static String fakeUserUserIdTwo = '6';

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

  const String fakeUserUserIDOne = '5';
  const String fakeUserUserIdTwo = '6';

  final MockNavigatorObserver mockNavigatorObserver = MockNavigatorObserver();
  final MockHttpProvider mockHttpProvider = MockHttpProvider();
  final MockStorageProvider mockStorageProvider = MockStorageProvider();

  const String DEFAULT_USER_ID = '1';
  const String DEFAULT_USERNAME = 'username';
  const String DEFAULT_DATE_OF_BIRTH = '2020-01-01';
  const String DEFAULT_GENDER = 'MALE';
  const String DEFAULT_DESC = 'desc';
  const String DEFAULT_CREATED_DATE = '2020-01-01';
  const String DEFAULT_PHOTO_URL = 'URL';
  const String DEFAULT_BUCKET = 'BUCKET';
  final Dog defaultDogOne = Dog(name:'dog1',uuid: "1");
  final Dog defaultDogTwo = Dog(name:'dog2', uuid: '2');
  final List<Dog> fakeUserDogList = [defaultDogOne, defaultDogTwo];

  const String FRIEND_ONE_ID = '5';
  const String FRIEND_TWO_ID = '6';
  const String FRIEND_ONE_NAME = 'friend1';
  const String FRIEND_TWO_NAME = 'friend2';
  final User defaultFriendOne = User(userId: FRIEND_ONE_ID, username: FRIEND_ONE_NAME);
  final User defaultFriendTwo = User(userId: FRIEND_TWO_ID, username: FRIEND_TWO_NAME);
  final List<User> fakeUserFriendList = [defaultFriendOne, defaultFriendTwo];


  final User fakeUser = User(userId: DEFAULT_USER_ID, username: DEFAULT_USERNAME, dateOfBirth: DEFAULT_DATE_OF_BIRTH, gender: DEFAULT_GENDER, desc: DEFAULT_DESC, createdDate: DEFAULT_CREATED_DATE, dogs: fakeUserDogList,photoUrl: DEFAULT_PHOTO_URL, bucket: DEFAULT_BUCKET, friends: fakeUserFriendList);

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

    Finder iconImage = find.byKey(Key('image$fakeUserUserIDOne'));
    Finder username = find.byKey(Key('username$fakeUserUserIDOne'));
    Finder chatBoxIcon = find.byKey(Key('chat$fakeUserUserIDOne'));
    Finder profileViewerIcon = find.byKey(Key('profileviewer$fakeUserUserIDOne'));

    expect(iconImage,findsOneWidget); // TWO USERS SHOULD SHOW ON PAGE. LOOK ON HTTPPROVIDER MOCK IMPLEMENTATION
    expect(username,findsOneWidget); // TWO USERS SHOULD SHOW ON PAGE. LOOK ON HTTPPROVIDER MOCK IMPLEMENTATION
    expect(chatBoxIcon,findsOneWidget); // TWO USERS SHOULD SHOW ON PAGE. LOOK ON HTTPPROVIDER MOCK IMPLEMENTATION
    expect(profileViewerIcon,findsOneWidget); // TWO USERS SHOULD SHOW ON PAGE. LOOK ON HTTPPROVIDER MOCK IMPLEMENTATION

    iconImage = find.byKey(Key('image$fakeUserUserIdTwo'));
    username = find.byKey(Key('username$fakeUserUserIdTwo'));
    chatBoxIcon = find.byKey(Key('chat$fakeUserUserIdTwo'));
    profileViewerIcon = find.byKey(Key('profileviewer$fakeUserUserIdTwo'));

    expect(iconImage,findsOneWidget); // TWO USERS SHOULD SHOW ON PAGE. LOOK ON HTTPPROVIDER MOCK IMPLEMENTATION
    expect(username,findsOneWidget); // TWO USERS SHOULD SHOW ON PAGE. LOOK ON HTTPPROVIDER MOCK IMPLEMENTATION
    expect(chatBoxIcon,findsOneWidget); // TWO USERS SHOULD SHOW ON PAGE. LOOK ON HTTPPROVIDER MOCK IMPLEMENTATION
    expect(profileViewerIcon,findsOneWidget); // TWO USERS SHOULD SHOW ON PAGE. LOOK ON HTTPPROVIDER MOCK IMPLEMENTATION
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

  testWidgets('Navigation: Tap on arrow -> PUSH Profileviewer', (tester)async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();

    await tester.runAsync(()async{
      await tester.enterText(searchBar, 'fake');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    });
    await tester.pumpAndSettle();

    Finder profileViewerIcon = find.byKey(Key('profileviewer$fakeUserUserIDOne')); //SEE FINDFRIENDS PAGE IMPLEMENTATION

    await tester.tap(profileViewerIcon);
    verify(mockNavigatorObserver.didPush(any, any));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileViewer), findsOneWidget);
  });

  testWidgets('Navigation: Tap on chatbox -> PUSH Messages', (tester)async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();

    await tester.runAsync(()async{
      await tester.enterText(searchBar, 'fake');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    });
    await tester.pumpAndSettle();

    Finder chatBoxIcon = find.byKey(Key('chat$fakeUserUserIDOne')); //SEE FINDFRIENDS PAGE IMPLEMENTATION

    await tester.tap(chatBoxIcon);
    verify(mockNavigatorObserver.didPush(any, any));
    await tester.pumpAndSettle();
    expect(find.byType(MessengerHandler), findsOneWidget);
  });
}