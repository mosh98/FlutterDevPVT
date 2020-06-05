
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:flutter_test/flutter_test.dart';



void main(){

  Dog DEFAULT_DOG1 = Dog(name: "dog1", uuid: "1");
  Dog DEFAULT_DOG2 = Dog(name: "dog2", uuid: "2");
  final int DOGLIST_LENGTH = 2;

  const DEFAULT_FRIEND1_USERID = "1010";
  const DEFAULT_FRIEND2_USERID = "2020";

  final User DEFAULT_FRIEND1 = User(username: 'friend1',userId: DEFAULT_FRIEND1_USERID);
  final User DEFAULT_FRIEND2 = User(username: 'friend2',userId: DEFAULT_FRIEND2_USERID);
  final int FRIENDLIST_LENGTH = 2;

  const String DEFAULT_USER_ID = '1';
  const String DEFAULT_USERNAME = 'username';
  const String DEFAULT_DATE_OF_BIRTH = '2020-01-01';
  const String DEFAULT_GENDER = 'MALE';
  const String DEFAULT_DESC = 'desc';
  const String DEFAULT_CREATED_DATE = '2020-01-01';
  const String DEFAULT_PHOTO_URL = 'URL';
  const String DEFAULT_BUCKET = 'BUCKET';


  List<User> createStaticFriendsList(){
    List<User> friendsList = [DEFAULT_FRIEND1, DEFAULT_FRIEND2];
    return friendsList;
  }

  List<dynamic> createStaticDogsList(){
    List<dynamic> dogList = [DEFAULT_DOG1, DEFAULT_DOG2];
    return dogList;
  }

  User createStaticUser(){
    List<User> friendsList = createStaticFriendsList();
    List<dynamic> dogList = createStaticDogsList();
    return User(userId: DEFAULT_USER_ID, username: DEFAULT_USERNAME, dateOfBirth: DEFAULT_DATE_OF_BIRTH, gender: DEFAULT_GENDER, desc: DEFAULT_DESC, createdDate: DEFAULT_CREATED_DATE, dogs: dogList, photoUrl: DEFAULT_PHOTO_URL, bucket: DEFAULT_BUCKET, friends: friendsList);
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
      expect(id, DEFAULT_USER_ID);
    });

    test('getName returns actual name', (){
      User user = createStaticUser();
      var username = user.getName();
      expect(username, DEFAULT_USERNAME);
    });

    test('getDateOfBirth returns actual date of birth', (){
      User user = createStaticUser();
      var dateOfBirth = user.getDateOfBirth();
      expect(dateOfBirth, DEFAULT_DATE_OF_BIRTH);
    });

    test('getGender returns actual gender', (){
      User user = createStaticUser();
      var gender = user.getGender();
      expect(gender, DEFAULT_GENDER);
    });

    test('getDesc returns actual desc', (){
      User user = createStaticUser();
      var desc = user.getDesc();
      expect(desc, DEFAULT_DESC);
    });

    test('getCreatedAt returns actual created at', (){
      User user = createStaticUser();
      var createdAt = user.getCreatedDate();
      expect(createdAt, DEFAULT_CREATED_DATE);
    });

    test('getDogs returns actual dog list', (){
      User user = createStaticUser();
      List<dynamic> dogs = user.getDogs();
      expect(dogs.length, DOGLIST_LENGTH);
      bool containsDogs = dogs.contains(DEFAULT_DOG1) && dogs.contains(DEFAULT_DOG2);
      expect(containsDogs, true);
    });

    test('getPhotoUrl returns actual photourl', (){
      User user = createStaticUser();
      var photoUrl = user.getPhotoUrl();
      expect(photoUrl, DEFAULT_PHOTO_URL);
    });

    test('getBucket returns actual bucket', (){
      User user = createStaticUser();
      var bucket = user.getBucket();
      expect(bucket, DEFAULT_BUCKET);
    });

    test('getFriends returns actual friends', (){
      User user = createStaticUser();
      List<User> friends = user.getFriends();
      expect(friends.length, FRIENDLIST_LENGTH);
      bool containsFriends = friends.contains(DEFAULT_FRIEND1) && friends.contains(DEFAULT_FRIEND2);
      expect(containsFriends, true);
    });
  });

  group('User - set methods', () {
    test('setDateOfBirth sets new birth', (){
      User user = createStaticUser();
      expect(user.getDateOfBirth(), DEFAULT_DATE_OF_BIRTH);
      user.setDateOfBirth('2020-02-02');
      expect(user.getDateOfBirth(), '2020-02-02');
    });

    test('setGender sets new gender', (){
      User user = createStaticUser();
      expect(user.getGender(), DEFAULT_GENDER);
      user.setGender('FEMALE');
      expect(user.getGender(), 'FEMALE');
    });

    test('setDesc sets new desc', (){
      User user = createStaticUser();
      expect(user.getDesc(), DEFAULT_DESC);
      user.setDescription('new_desc');
      expect(user.getDesc(), 'new_desc');
    });

    test('setURL sets new url', (){
      User user = createStaticUser();
      expect(user.getPhotoUrl(), DEFAULT_PHOTO_URL);
      user.setPhotoUrl('new_url');
      expect(user.getPhotoUrl(), 'new_url');
    });

    test('add dog adds new dog', (){
      User user = createStaticUser();
      expect(user.getDogs().length, DOGLIST_LENGTH);
      Dog dog = new Dog();
      user.addDog(dog);
      expect(user.getDogs().length, 3);
      bool hasDog = user.getDogs().contains(dog);
      expect(hasDog, true);
    });

    test('remove dog removes dog', (){
      User user = createStaticUser();
      expect(user.getDogs().length, DOGLIST_LENGTH);
      user.removeDog(DEFAULT_DOG1);
      expect(user.getDogs().length, 1);
      bool hasDog = !user.getDogs().contains(DEFAULT_DOG1);
      expect(hasDog, true);
    });

    test('add friend adds new friend', (){
      User user = createStaticUser();
      expect(user.getFriends().length, FRIENDLIST_LENGTH);
      User newFriend = User();
      user.addFriend(newFriend);
      expect(user.getFriends().length, 3);
      bool hasFriend = user.getFriends().contains(newFriend);
      expect(hasFriend, true);
    });

    test('remove friend removes friend', (){
      User user = createStaticUser();
      expect(user.getFriends().length, FRIENDLIST_LENGTH);
      user.removeFriend(DEFAULT_FRIEND1);
      expect(user.getFriends().length, 1);
      bool hasFriend = !user.getFriends().contains(DEFAULT_FRIEND1);
      expect(hasFriend, true);
    });
  });

  group('User - testing inputs of setters', () {
    test('input null to addFriend should return false and not add', (){
      User user = createStaticUser();
      bool addedFriend = user.addFriend(null);
      expect(addedFriend, false);
    });

    test('input a friend that already exists does not add and returns false', (){
      User user = createStaticUser();
      User friendThatExists = User(userId: DEFAULT_FRIEND1_USERID);
      bool addedFriend = user.addFriend(friendThatExists);
      int timesExist = 0;
      user.getFriends().forEach((element) {
        if(element.userId == DEFAULT_FRIEND1_USERID)
          ++timesExist;
      });
      expect(timesExist, 1);
      expect(addedFriend, false);
    });

    test('input null to removeFriend should return false', (){
      User user = createStaticUser();
      bool removedFriend = user.removeFriend(null);
      expect(removedFriend, false);
    });

    test('input existing friend to removeFriend should return true', (){
      User user = createStaticUser();
      bool removedFriend = user.removeFriend(DEFAULT_FRIEND1);
      expect(removedFriend, true);
    });

    test('input null to removeDog should return false', (){
      User user = createStaticUser();
      bool removedDog = user.removeDog(null);
      expect(removedDog, false);
    });

    test('input existing dog to removeDog should return true', (){
      User user = createStaticUser();
      bool removedDog = user.removeDog(DEFAULT_DOG1);
      expect(removedDog, true);
    });

    test('input null to addDog should return false', (){
      User user = createStaticUser();
      bool removedDog = user.addDog(null);
      expect(removedDog, false);
    });
  });
}