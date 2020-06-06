
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/ProfilePage.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockStorageProvider extends Mock implements StorageProvider{

}

void main() {

  const String DEFAULT_USER_ID = '1';
  const String DEFAULT_USERNAME = 'username';
  const String DEFAULT_DATE_OF_BIRTH = '2020-01-01';
  const String DEFAULT_GENDER = 'MALE';
  const String DEFAULT_DESC = 'desc';
  const String DEFAULT_CREATED_DATE = '2020-01-01';
  const String DEFAULT_PHOTO_URL = 'URL';
  const String DEFAULT_BUCKET = 'BUCKET';
  final User fakeUser = User(userId: DEFAULT_USER_ID, username: DEFAULT_USERNAME, dateOfBirth: DEFAULT_DATE_OF_BIRTH, gender: DEFAULT_GENDER, desc: DEFAULT_DESC, createdDate: DEFAULT_CREATED_DATE, dogs: [Dog(uuid: '1'),Dog(uuid: '2')],photoUrl: DEFAULT_PHOTO_URL, bucket: DEFAULT_BUCKET, friends: [User(userId: '5'),User(userId: '6')]);

  MockStorageProvider storageProvider = MockStorageProvider();

  final ProfilePage profilePage = ProfilePage(user: fakeUser, storageProvider: storageProvider);
  final Widget page = MaterialApp(
    home: profilePage,
  );

  testWidgets('Rendering page', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
  });

}
