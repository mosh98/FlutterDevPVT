class Dog{
  final String name;
  final String breed;
  final String dateOfBirth;
  final String gender;
  final bool neutered;
  final String description;

  Dog({this.name, this.breed, this.dateOfBirth, this.gender, this.neutered, this.description});

  factory Dog.fromJson(Map<String, dynamic> json){
    return Dog(
      name: json['name'],
      breed: json['breed'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      neutered: json['neutered'],
      description: json['description'],
    );
  }
}