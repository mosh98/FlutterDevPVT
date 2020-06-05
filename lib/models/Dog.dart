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

  //TODO: HERE , TEST REMOVE SPACES
  setName(String name){
    if(name == null || name.trim().isEmpty){
      return;
    }
    this.name = name;
  }

  setGender(String gender){
    if(gender == null || gender.trim().isEmpty){
      return;
    }
    this.gender = gender;
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

  setDescription(String desc){
    this.description = desc;
  }

  @override
  bool operator ==(other) {
    if(other is! Dog)
      return false;
    return uuid == (other as Dog).uuid;
  }

  int _hash;
  @override
  int get hashCode{
   if(_hash == null)
     _hash = uuid.hashCode;
   return _hash;
  }
}