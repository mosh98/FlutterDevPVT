
import 'package:dog_prototype/dialogs/DogDialog.dart';
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/FriendPage.dart';
import 'package:dog_prototype/pages/ProfilePage.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/services/HttpProvider.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockStorageProvider extends Mock implements StorageProvider{
  @override
  getProfileImage() {
    return null;
  }
}

class MockHttpProvider extends Mock implements HttpProvider{
  @override
  Future<bool> updateDescriptionUser(String desc) async{
    return true;
  }

  @override
  Future<Dog> addDog(String dogName, String breed, String dateOfBirth, String gender, bool neut) async{
    return Dog(name: dogName);
  }

  @override
  Future<bool> deleteDog(Dog dog) async{
    return true;
  }
}

class MockIdTokenResult extends Mock implements IdTokenResult{
  @override
  String get token => "token";
}

class MockFirebaseUser extends Mock implements FirebaseUser{
  @override
  Future<IdTokenResult> getIdToken({bool refresh = false}) async{
    MockIdTokenResult tokenResult = MockIdTokenResult();
    return tokenResult;
  }
}

class MockAuthService extends Mock implements AuthService{

  @override
  Future<FirebaseUser> getCurrentFirebaseUser() async{
    MockFirebaseUser mockFirebaseUser = MockFirebaseUser();
    return mockFirebaseUser;
  }

  @override
  Future<User> createUserModel(Future<IdTokenResult> token) async{
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

    return User(userId: DEFAULT_USER_ID, username: DEFAULT_USERNAME, dateOfBirth: DEFAULT_DATE_OF_BIRTH, gender: DEFAULT_GENDER, desc: DEFAULT_DESC, createdDate: DEFAULT_CREATED_DATE, dogs: fakeUserDogList,photoUrl: DEFAULT_PHOTO_URL, bucket: DEFAULT_BUCKET, friends: fakeUserFriendList);
  }
}

class MockNavigatorObserver extends Mock implements NavigatorObserver{}

void main() {

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

  MockStorageProvider storageProvider = MockStorageProvider();
  MockHttpProvider httpProvider = MockHttpProvider();
  MockNavigatorObserver mockObserver = MockNavigatorObserver();
  MockAuthService mockAuthService = MockAuthService();

  final ProfilePage profilePage = ProfilePage(user: fakeUser, storageProvider: storageProvider, httpProvider: httpProvider,authService: mockAuthService,);

  final Widget page = new MediaQuery(
    data: new MediaQueryData(),
    child: MaterialApp(
      home:profilePage,
      navigatorObservers: [mockObserver],
    )
  );

  Finder settingsButton = find.byKey(Key('settings'));
  Finder imageHolder = find.byKey(Key('imageholder'));
  Finder friendsButton = find.byKey(Key('friends'));
  Finder aboutHelper = find.byKey(Key('about'));
  Finder editButton = find.byKey(Key('edit'));
  Finder gestureEditButton = find.byKey(Key('aboutgesture'));
  Finder myDogsHelper = find.byKey(Key('mydogs'));
  Finder addDogButton = find.byKey(Key('addog'));
  Finder dogList = find.byKey(Key('doglistview'));


  testWidgets('Rendering page', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
  });


  testWidgets('Find information about user', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();

    Finder username = find.text(DEFAULT_USERNAME);
    Finder desc = find.text(DEFAULT_DESC);
    fakeUserDogList.forEach((element) {
      Finder name = find.text(element.getName());
      expect(name, findsOneWidget);
    });
    expect(username, findsOneWidget);
    expect(desc, findsOneWidget);
  });

  testWidgets('Find widgets', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    expect(settingsButton, findsOneWidget);
    expect(imageHolder, findsOneWidget);
    expect(friendsButton, findsOneWidget);
    expect(aboutHelper, findsOneWidget);
    expect(editButton, findsOneWidget);
    expect(gestureEditButton, findsOneWidget);
    expect(myDogsHelper, findsOneWidget);
    expect(addDogButton, findsOneWidget);
    expect(dogList, findsOneWidget);
  });

  testWidgets('Navigation: SettingsButton -> PUSH', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    await tester.tap(settingsButton);

    verify(mockObserver.didPush(any, any));
  });

  testWidgets('Navigation: FriendsButton -> PUSH', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    await tester.tap(friendsButton);

    verify(mockObserver.didPush(any, any));
    await tester.pumpAndSettle();

    expect(find.byType(FriendPage), findsOneWidget);
  });

  testWidgets('Find FriendPage widgets', (tester)async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    await tester.tap(friendsButton);
    verify(mockObserver.didPush(any, any));
    await tester.pumpAndSettle();

    Finder searchField = find.byKey(Key('search'));
    Finder listViewBuilder = find.byKey(Key('builder'));

    expect(searchField, findsOneWidget);
    expect(listViewBuilder, findsOneWidget);
  });

  testWidgets('Find FriendPage actually shows friends', (tester)async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    await tester.tap(friendsButton);
    verify(mockObserver.didPush(any, any));
    await tester.pumpAndSettle();

    fakeUser.friends.forEach((element) {
      expect(find.text(element.getName()),findsOneWidget);
    });
  });

  testWidgets('Find FriendPage -SEARCH- actually searches for friend', (tester)async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    await tester.tap(friendsButton);
    verify(mockObserver.didPush(any, any));
    await tester.pumpAndSettle();

    Finder searchField = find.byKey(Key('search'));
    await tester.enterText(searchField, "1"); // SUB-STRING OF FRIEND ONE
    await tester.pumpAndSettle();

    expect(find.text(FRIEND_ONE_NAME), findsOneWidget);
    expect(find.text(FRIEND_TWO_NAME), findsNothing);

    await tester.enterText(searchField, "2"); // SUB-STRING OF FRIEND TWO
    await tester.pumpAndSettle();

    expect(find.text(FRIEND_TWO_NAME), findsOneWidget);
    expect(find.text(FRIEND_ONE_NAME), findsNothing);

    await tester.enterText(searchField, "friend"); //SUB-STRING OF BOTH FRIENDS
    await tester.pumpAndSettle();
    expect(find.text(FRIEND_ONE_NAME), findsOneWidget);
    expect(find.text(FRIEND_TWO_NAME), findsOneWidget);
  });



  testWidgets('Navigation: EditButton -> PUSH', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    await tester.tap(editButton);

    verify(mockObserver.didPush(any, any));
  });

  testWidgets('Find Edit-widget widgets', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    Finder editTextTextField = find.byKey(Key('editdesctextfield'));
    Finder dialogEditButtonDone = find.byKey(Key('dialogeditbuttondone'));
    Finder dialogEditButtonBack = find.byKey(Key('dialogeditbuttonback'));

    expect(editTextTextField, findsOneWidget);
    expect(dialogEditButtonDone, findsOneWidget);
    expect(dialogEditButtonBack, findsOneWidget);
  });

  testWidgets('Edit about text actually edits text', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    Finder editTextTextField = find.byKey(Key('editdesctextfield'));

    expect(editTextTextField, findsOneWidget);

    await tester.enterText(editTextTextField, 'newdesc');
    expect(find.text('newdesc'), findsOneWidget);

    Finder dialogEditButtonDone = find.byKey(Key('dialogeditbuttondone'));

    expect(dialogEditButtonDone, findsOneWidget);

    await tester.tap(dialogEditButtonDone);
    verify(mockObserver.didPop(any, any));
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage), findsOneWidget);

    expect(find.text('newdesc'),findsOneWidget);

    expect(fakeUser.getDesc(), 'newdesc');
  });

  testWidgets('Navigation: dialogEditButtonBack -> POP', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    Finder dialogEditButtonBack = find.byKey(Key('dialogeditbuttonback'));

    expect(dialogEditButtonBack, findsOneWidget);

    await tester.tap(dialogEditButtonBack);
    verify(mockObserver.didPop(any, any));
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage), findsOneWidget);
  });

  testWidgets('Navigation: Add Dog -> PUSH', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    await tester.tap(addDogButton);

    verify(mockObserver.didPush(any, any));
    await tester.pumpAndSettle();

    expect(find.byType(DogDialog), findsOneWidget);
  });

  testWidgets('Navigation: back button on dog dialog -> POP', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    await tester.tap(addDogButton);

    verify(mockObserver.didPush(any, any));
    await tester.pumpAndSettle();

    Finder backButton = find.byKey(Key('back'));

    await tester.tap(backButton);
    verify(mockObserver.didPop(any, any));
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
  });

  testWidgets('Find Add Dog-widget widgets', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    await tester.tap(addDogButton);
    await tester.pumpAndSettle();

    Finder information = find.text('Information about your dog');
    Finder backButton = find.byKey(Key('back'));
    Finder nameField = find.byKey(Key('namefield'));
    Finder breedField = find.byKey(Key('breedfield'));
    Finder genderDropDown = find.byKey(Key('gender'));
    Finder neuteredDropDown = find.byKey(Key('neutered'));
    Finder dateOfBirth = find.byKey(Key('dateofbirth'));
    Finder addDogDialogButton = find.byKey(Key('add'));

    expect(information, findsOneWidget);
    expect(backButton, findsOneWidget);
    expect(nameField, findsOneWidget);
    expect(breedField, findsOneWidget);
    expect(genderDropDown, findsOneWidget);
    expect(neuteredDropDown, findsOneWidget);
    expect(dateOfBirth, findsOneWidget);
    expect(addDogDialogButton, findsOneWidget);
  });

  testWidgets('Add dog actually adds dog', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    await tester.tap(addDogButton);
    verify(mockObserver.didPush(any, any));
    await tester.pumpAndSettle();

    Finder nameField = find.byKey(Key('namefield'));
    Finder breedField = find.byKey(Key('breedfield'));
    Finder addDogDialogButton = find.byKey(Key('add'));

    await tester.enterText(nameField, "testnewdog");
    expect(find.text("testnewdog"),findsOneWidget);

    await tester.enterText(breedField, "testnewbreed");
    expect(find.text("testnewbreed"), findsOneWidget);

    await tester.tap(addDogDialogButton);
    verify(mockObserver.didPop(any, any));
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage),findsOneWidget);

    Finder dog = find.text("testnewdog");

    expect(dog,findsOneWidget);
  });

  testWidgets('Navigation: Remove Dog -> PUSH', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    verify(mockObserver.didPush(any, any));

    Finder aDeleteDogButton = find.byKey(Key('removedog${fakeUser.dogs[1].getUUID()}'));
    expect(aDeleteDogButton, findsOneWidget);

    await tester.tap(aDeleteDogButton);
    verify(mockObserver.didPush(any, any));
    await tester.pumpAndSettle();

    Finder deleteDogDialog = find.byKey(Key('deletedogdialog'));
    expect(deleteDogDialog, findsOneWidget);
  });

  testWidgets('Navigation: Back button on Remove Dog Widget -> POP', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    verify(mockObserver.didPush(any, any));

    Finder aDeleteDogButton = find.byKey(Key('removedog${fakeUser.dogs[1].getUUID()}'));

    await tester.tap(aDeleteDogButton);
    verify(mockObserver.didPush(any, any));
    await tester.pumpAndSettle();

    Finder noButton = find.byKey(Key('nobutton'));
    await tester.tap(noButton);

    verify(mockObserver.didPop(any, any));
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
  });

  testWidgets('Find Remove Dog Dialog widgets', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    verify(mockObserver.didPush(any, any));

    Finder aDeleteDogButton = find.byKey(Key('removedog${fakeUser.dogs[1].getUUID()}'));
    expect(aDeleteDogButton, findsOneWidget);

    await tester.tap(aDeleteDogButton);
    verify(mockObserver.didPush(any, any));
    await tester.pumpAndSettle();

    Finder information = find.byKey(Key('information'));
    Finder noButton = find.byKey(Key('nobutton'));
    Finder yesButton = find.byKey(Key('yesbutton'));

    expect(information,findsOneWidget);
    expect(noButton,findsOneWidget);
    expect(yesButton,findsOneWidget);
  });

  testWidgets('Remove dog actually removes dog', (tester) async{
    String deletedDogName = fakeUser.dogs[1].getName();
    String UUIDDeletedDog = fakeUser.dogs[1].getUUID();

    bool hasDog = fakeUser.dogs.contains(Dog(uuid:UUIDDeletedDog));

    expect(hasDog, true);

    final Widget anotherPage = new MediaQuery(
        data: new MediaQueryData(),
        child: MaterialApp(
          home:Scaffold(
            body: profilePage,
          ),
          navigatorObservers: [mockObserver],
        )
    );

    await tester.pumpWidget(anotherPage);
    await tester.pumpAndSettle();
    verify(mockObserver.didPush(any, any));
    expect(find.text(deletedDogName), findsOneWidget);

    Finder aDeleteDogButton = find.byKey(Key('removedog${fakeUser.dogs[1].getUUID()}'));
    expect(aDeleteDogButton, findsOneWidget);

    await tester.tap(aDeleteDogButton);
    verify(mockObserver.didPush(any, any));
    await tester.pumpAndSettle();

    Finder yesButton = find.byKey(Key('yesbutton'));

    await tester.tap(yesButton);
    verify(mockObserver.didPop(any, any));
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage),findsOneWidget);

    expect(find.text(deletedDogName),findsNothing);

    hasDog = fakeUser.dogs.contains(Dog(uuid:UUIDDeletedDog));

    expect(hasDog, false);
  });
}
