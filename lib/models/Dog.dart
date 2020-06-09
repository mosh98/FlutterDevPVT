class Dog{
  String name;
  String breed;
  String dateOfBirth;
  String gender;
  bool neutered;
  String description;
  final String uuid;

  Dog({this.name, this.breed, this.dateOfBirth, this.gender, this.neutered, this.description, this.uuid});

  factory Dog.fromJson(Map<String, dynamic> json){
    return Dog(
      name: json['name'],
      breed: json['breed'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      neutered: json['neutered'],
      description: json['description'],
      uuid: json['uuid']
    );
  }

  String getName(){
    return name;
  }

  String getBreed(){
    return breed;
  }

  String getDateOfBirth(){
    return dateOfBirth;
  }

  String getGender(){
    return gender;
  }

  String getNeutered(){
    if(neutered == true){
      return 'Yes';
    }else{
      return 'No';
    }
  }

  String getDescription(){
    return description;
  }

  String getUUID(){
    return uuid;
  }

  setName(String name){
    if(name == null || name.trim().isEmpty){
      return;
    }
    this.name = name.trim();
  }

  setGender(String gender){
    if(gender == null || gender.trim().isEmpty){
      return;
    }
    this.gender = gender.trim();
  }

  setBreed(String breed){
    if(breed == null || breed.trim().isEmpty){
      return;
    }
    this.breed = breed.trim();
  }

  setDateOfBirth(String dateOfBirth){
    if(dateOfBirth == null || dateOfBirth.trim().isEmpty){
      return;
    }
    this.dateOfBirth = dateOfBirth.trim();
  }

  setNeutered(bool neutered){
    if(neutered == null){
      return;
    }
    this.neutered = neutered;
  }

  setDescription(String desc){
    if(desc == null || desc.trim().isEmpty){
      return;
    }
    this.description = desc.trim();
  }

  @override
  bool operator ==(other) {
    if(other is! Dog)
      return false;
    return other is Dog && this.uuid == other.uuid;
  }

  int _hash;
  @override
  int get hashCode{
   if(_hash == null)
     _hash = uuid.hashCode;
   return _hash;
  }
}