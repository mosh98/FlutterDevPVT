class Dog{
  String name;
  String breed;
  String dateOfBirth;
  String gender;
  bool neutered;
  String description;

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

  setName(String name){
    this.name = name;
  }

  setBreed(String breed){
    this.breed = breed;
  }

  setDateOfBirth(String dateOfBirth){
    this.dateOfBirth = dateOfBirth;
  }

  setNeutered(bool neutered){
    this.neutered = neutered;
  }

  setGender(String gender){
    this.gender = gender;
  }

  setDescription(String desc){
    this.description = desc;
  }

  getNeutered(){
    if(neutered = true){
      return 'Yes';
    }else{
      return 'No';
    }
  }
}