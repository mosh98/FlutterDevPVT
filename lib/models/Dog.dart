class Dog{
  final String username;
  final String email;
  final String dateOfBirth;
  final String gender;
  final String desc;
  final String createdDate;
  final List<dynamic> dogs;

  Dog({this.username, this.email, this.dateOfBirth, this.gender, this.desc, this.createdDate, this.dogs});

  factory Dog.fromJson(Map<String, dynamic> json){
    return Dog(
      username: json['username'],
      email: json['email'],
      dateOfBirth: json['date_of_birth'],
      desc: json['description'],
      createdDate: json['createdAt'],
      dogs: json['dogs'],
    );
  }

  String getName(){return username;}
  String getEmail(){return email;}
  String getDateOfBirth(){return dateOfBirth;}
  String getGender(){return gender;}
  String getDesc(){return desc;}
  String getCreatedDate(){return createdDate;}
  List<dynamic> getDogs(){return dogs;}
}