import 'Dog.dart';

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

  User({this.userId,this.username, this.dateOfBirth, this.gender, this.desc, this.createdDate, this.dogs, this.photoUrl, this.bucket});

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      userId: json['userId'],
      username: json['username'],
      //email: json['email'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      desc: json['description'],
      createdDate: json['createdAt'],
      dogs: json['dogs'],
      photoUrl: json['photoUrl'],
      bucket: json['bucket']
    );
  }

  String getName(){return username;}
  //String getEmail(){return email;}
  String getDateOfBirth(){return dateOfBirth;}
  String getGender(){return gender;}
  String getDesc(){return desc;}
  String getCreatedDate(){return createdDate;}
  List getDogs(){return dogs;}

  //void setEmail(String email){this.email = email;}

  void setPhotoUrl(String photoUrl){this.photoUrl = photoUrl;}

  void setDescription(String desc){this.desc = desc;}

  void setGender(String gender){this.gender = gender;}

  void setDateOfBirth(String dateOfBirth){this.dateOfBirth = dateOfBirth;}

  void addDog(Dog dog){dogs.add(dog);}

  @override
  String toString() {
    return "Name: $username Date of birth: $dateOfBirth Gender: $gender Description: $desc Created at: $createdDate Dogs: $dogs";
  }
}