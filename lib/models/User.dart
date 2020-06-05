import 'package:dog_prototype/services/Authentication.dart';

import 'Dog.dart';

enum ProviderState{FacebookUser, EmailUser}

class User{
  final String username;
  String dateOfBirth;
  String gender;
  String desc;
  final String createdDate;
  final List<dynamic> dogs;
  String photoUrl;
  String userId;
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
      dogs: json['dogs'],
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
  List getDogs(){return dogs;}
  String getBucket(){return bucket;}
  List<User> getFriends(){return friends;}

  void setPhotoUrl(String photoUrl){this.photoUrl = photoUrl;}

  void setDescription(String desc){this.desc = desc;}

  void setGender(String gender){this.gender = gender;}

  void setDateOfBirth(String dateOfBirth){this.dateOfBirth = dateOfBirth;}

  void addDog(Dog dog){dogs.add(dog);}

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