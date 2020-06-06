import 'package:dog_prototype/services/Authentication.dart';

import 'Dog.dart';

enum ProviderState{FacebookUser, EmailUser}

class User{
  final String username;
  String dateOfBirth;
  String gender;
  String desc;
  final String createdDate;
  final List<Dog> dogs;
  String photoUrl;
  final String userId;
  final bucket;
  final List<User> friends;

  getProvider() async{
    bool facebookUser = await AuthService().getProvider();
    if(facebookUser)
      return ProviderState.FacebookUser;
    return ProviderState.EmailUser;
  }

  User({
    this.userId,
    this.username,
    this.dateOfBirth,
    this.gender,
    this.desc,
    this.createdDate,
    this.dogs,
    this.photoUrl,
    this.bucket,
    this.friends,
  }
    );

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      userId: json['userId'],
      username: json['username'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      desc: json['description'],
      createdDate: json['createdAt'],
      dogs: _getDogs(json['dogs']),
      photoUrl: json['photoUrl'],
      bucket: json['bucket'],
      friends: _getFriends(json['friends']),
    );
  }

  String getId(){return userId;}
  String getName(){return username;}
  String getDateOfBirth(){return dateOfBirth;}
  String getGender(){return gender;}
  String getDesc(){return desc;}
  String getCreatedDate(){return createdDate;}
  String getPhotoUrl(){return photoUrl;}
  List<Dog> getDogs(){return dogs;}
  String getBucket(){return bucket;}
  List<User> getFriends(){return friends;}

  void setPhotoUrl(String photoUrl){this.photoUrl = photoUrl;}

  void setDescription(String desc){this.desc = desc;}

  void setGender(String gender){this.gender = gender;}

  void setDateOfBirth(String dateOfBirth){this.dateOfBirth = dateOfBirth;}

  bool addDog(dynamic dog){
    if(dog == null)
      return false;
    dogs.add(dog);
    return true;
  }

  bool removeDog(Dog dog){
    if(dog == null)
      return false;
    return dogs.remove(dog);
  }

  bool addFriend(User friend){
    if(friend == null || friends.contains(friend))
      return false;
    friends.add(friend);
    return true;
  }

  bool removeFriend(User friend){
    if(friend == null)
      return false;
    return friends.remove(friend);
  }

  static List<User> _getFriends(List<dynamic> friends){
    List<User> convertedFriends = List<User>();

    if(friends == null || friends.isEmpty)
      return convertedFriends;

    friends.forEach((element) {
      User friend = User.fromJson(element);
      convertedFriends.add(friend);
    });

    return convertedFriends;
  }

  static List<Dog> _getDogs(List<dynamic> dogs){
    List<Dog> convertedDogs = List<Dog>();

    if(dogs == null || dogs.isEmpty)
      return convertedDogs;

    dogs.forEach((element) {
      Dog dog = Dog.fromJson(element);
      convertedDogs.add(dog);
    });

    return convertedDogs;
  }

  @override
  bool operator ==(other) {
    if(other is! User)
      return false;
    return userId == (other as User).userId;
  }

  int _hash;
  @override
  int get hashCode{
    if(_hash == null){
      _hash = userId.hashCode;
    }
    return _hash;
  }

  @override
  String toString() {
    return "Name: $username Date of birth: $dateOfBirth Gender: $gender Description: $desc Created at: $createdDate Dogs: $dogs";
  }
}