
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/DogProfileViewer.dart';
import 'package:dog_prototype/pages/profileViewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dog_prototype/services/HttpProvider.dart';
import 'package:dog_prototype/services/StorageProvider.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver{}
class MockStorageProvider extends Mock implements StorageProvider{
  @override
  getOtherProfileImage(User user) {
    return null;
  }

  @override
  Future<String> getProfileImageDog(Dog dog) {
    return null;
  }
}
class MockHttpProvider extends Mock implements HttpProvider{
  @override
  Future<bool> addFriend(User friend) async{
    return true;
  }
}

void main(){
  MockNavigatorObserver mockNavigatorObserver = MockNavigatorObserver();
  MockStorageProvider mockStorageProvider = MockStorageProvider();
  MockHttpProvider mockHttpProvider = MockHttpProvider();

  const String DEFAULT_NAME_OTHERUSER = 'username';
  const String DEFAULT_DESCRIPTION_OTHERUSER = 'desc';

  const String DEFAULT_DOGNAME_ONE = 'nameOne';
  const String DEFAULT_DOG_BREED = 'breed';
  const String DEFAULT_DOG_DATE_OF_BIRTH = '2020-01-01';
  const bool DEFAULT_NEUTERED = false;
  const String DEFAULT_GENDER = 'MALE';
  const String DEFAULT_DESCRIPTION = 'decs';
  const String DEFAULT_DOGNAME_TWO = 'nameTwo';
  const String DEFAULT_DOGONE_ID = '1';
  const String DEFAULT_DOGTWO_ID = '2';
  final Dog dog = Dog(name: DEFAULT_DOGNAME_ONE,uuid: DEFAULT_DOGONE_ID,breed: DEFAULT_DOG_BREED, dateOfBirth: DEFAULT_DOG_DATE_OF_BIRTH, neutered: DEFAULT_NEUTERED, gender: DEFAULT_GENDER, description: DEFAULT_DESCRIPTION);
  final Dog anotherDog = Dog(name: DEFAULT_DOGNAME_TWO,uuid: DEFAULT_DOGTWO_ID);
  final List<Dog> dogList = [dog, anotherDog];

  const String DEFAULT_NAME_USER = 'username1';
  final List<User> userList = [];

  User fakeUser = User(username: DEFAULT_NAME_USER, friends: userList);
  User fakeOtherUser = User(username: DEFAULT_NAME_OTHERUSER, desc: DEFAULT_DESCRIPTION_OTHERUSER, dogs: dogList);

  ProfileViewer viewer = ProfileViewer(currentUser: fakeUser, otherUser: fakeOtherUser,httpProvider: mockHttpProvider,storageProvider: mockStorageProvider,);

  Finder addFriendIcon = find.byKey(Key('addfriend'));
  Finder nameBar = find.byKey(Key('usernamebar'));
  Finder nameField = find.byKey(Key('username'));
  Finder descField = find.byKey(Key('description'));
  Finder dogField = find.byKey(Key('dogs'));

  Widget page = MaterialApp(
    home: Scaffold(
      body: viewer,
    ),
    navigatorObservers: [mockNavigatorObserver],
  );

  group('default', () {
    testWidgets('Rendering page', (tester)async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();
      expect(find.byType(ProfileViewer), findsOneWidget);
    });

    testWidgets('Finding widgets', (tester)async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      expect(addFriendIcon, findsOneWidget);
      expect(nameBar, findsOneWidget);
      expect(nameField, findsOneWidget);
      expect(descField, findsOneWidget);
      expect(dogField, findsOneWidget);
    });

    testWidgets('Page displays correct data', (tester)async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      expect(addFriendIcon, findsOneWidget); //USERS ARE NOT FRIENDS
      expect(find.text(DEFAULT_NAME_OTHERUSER), findsNWidgets(2));
      expect(find.text(DEFAULT_DESCRIPTION_OTHERUSER), findsOneWidget);

      dogList.forEach((element) {
        expect(find.byKey(Key('${element.uuid}')), findsOneWidget);
      });

      await tester.tap(addFriendIcon);
      await tester.pumpAndSettle();

      Finder removeFriend = find.byKey(Key('removefriend'));

      expect(removeFriend, findsOneWidget);
    });
  });

  group('Navigation', () {
    testWidgets('Navigation: Click on other users dog -> PUSH', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      Finder aUserDog = find.byKey(Key('${DEFAULT_DOGONE_ID}'));

      await tester.tap(aUserDog);
      verify(mockNavigatorObserver.didPush(any, any));
      await tester.pumpAndSettle();

      expect(find.byType(DogProfileViewer), findsOneWidget);
    });
  });
}