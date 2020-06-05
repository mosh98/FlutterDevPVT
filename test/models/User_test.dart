
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:flutter_test/flutter_test.dart';



void main(){

  Dog dog1 = Dog(name: "dog1");
  Dog dog2 = Dog(name: "dog2");
  final List<dynamic> dogList = [dog1, dog2];
  final int DOGLIST_LENGTH = dogList.length;

  User friend1 = User(username: 'friend1');
  User friend2 = User(username: 'friend2');
  final List<User> friendsList = [friend1, friend2];
  final int FRIENDLIST_LENGTH = friendsList.length;


  User createStaticUser(){
    return User(userId: "1", username: "username", dateOfBirth: "2020-01-01", gender: "MALE", desc: "desc", createdDate: "2020-01-01", dogs: dogList, photoUrl: "URL", bucket: "BUCKET", friends: [User(), User()]);
  }

  group('User - testing default functionality', () {
    test('create user does not return null', (){
      User user = User();
      expect(user, isNot(null));

      user = createStaticUser();
      expect(user, isNot(null));
    });

    test('equals method returning true on same object',(){
      User user = createStaticUser();
      User anotherUser = User(userId: "1"); //SAME ID AS USER
      bool sameObject = user == anotherUser;
      expect(sameObject, true);
    });

    test('equals method returning false on different objects',(){
      User user = createStaticUser();
      User anotherUser = User(userId: "2"); //NOT SAME ID AS USER
      bool sameObject = user == anotherUser;
      expect(sameObject, false);
    });

    test('hash method returning same hashcode on same object',(){
      User user = createStaticUser();
      int hashCodeFirst = user.hashCode;
      int hashCodeSecond = user.hashCode;
      expect(hashCodeFirst, hashCodeSecond);
    });

    test('hash method returning different hashcodes on different objects with different id',(){
      User user = createStaticUser();
      int hashCodeFirst = user.hashCode;
      User anotherUser = User(userId: "2"); // DIFFERENT ID FROM USER
      int hashCodeSecond = anotherUser.hashCode;
      bool sameHash = hashCodeFirst == hashCodeSecond;
      expect(sameHash, false);
    });

    test('hash method returning same hashcodes on different objects with same id',(){
      User user = createStaticUser();
      int hashCodeFirst = user.hashCode;
      User anotherUser = User(userId: "1"); // SAME ID AS USER
      int hashCodeSecond = anotherUser.hashCode;
      bool sameHash = hashCodeFirst == hashCodeSecond;
      expect(sameHash, true);
    });
  });

  group('User - get methods', () {
    test('getId returns actual id', (){
      User user = createStaticUser();
      var id = user.getId();
      expect(id, "1");
    });

    test('getName returns actual name', (){
      User user = createStaticUser();
      var username = user.getName();
      expect(username, "username");
    });

    test('getDateOfBirth returns actual date of birth', (){
      User user = createStaticUser();
      var dateOfBirth = user.getDateOfBirth();
      expect(dateOfBirth, "2020-01-01");
    });

    test('getGender returns actual gender', (){
      User user = createStaticUser();
      var gender = user.getGender();
      expect(gender, "MALE");
    });

    test('getDesc returns actual desc', (){
      User user = createStaticUser();
      var desc = user.getDesc();
      expect(desc, "desc");
    });

    test('getCreatedAt returns actual created at', (){
      User user = createStaticUser();
      var createdAt = user.getCreatedDate();
      expect(createdAt, "2020-01-01");
    });

    test('getDogs returns actual dog list', (){
      User user = createStaticUser();
      List<dynamic> dogs = user.getDogs();
      expect(dogs.length, DOGLIST_LENGTH);
      Matcher matcher = unorderedEquals(dogList);
      expect(dogs, matcher);
    });

    test('getPhotoUrl returns actual photourl', (){
      User user = createStaticUser();
      var photoUrl = user.getPhotoUrl();
      expect(photoUrl, 'URL');
    });

    test('getBucket returns actual bucket', (){
      User user = createStaticUser();
      var bucket = user.getBucket();
      expect(bucket, 'BUCKET');
    });

    test('getFriends returns actual friends', (){
      User user = createStaticUser();
      List<User> friends = user.getFriends();
      expect(friends.length, FRIENDLIST_LENGTH);
      Matcher matcher = unorderedEquals(friends);
      expect(friends, matcher);
    });
  });
}