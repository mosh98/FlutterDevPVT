
import 'package:dog_prototype/models/Dog.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){

  const String DEFAULT_NAME = 'name';
  const String DEFAULT_BREED = 'breed';
  const String DEFAULT_DATE_OF_BIRTH = '2020-01-01';
  const String DEFAULT_GENDER = 'MALE';
  const bool DEFAULT_NEUTERED = false;
  const String DEFAULT_DESCRIPTION = 'desc';
  const String DEFAULT_UUID = "1";

  Dog createStaticDog(){
    return Dog(name: DEFAULT_NAME, breed: DEFAULT_BREED, dateOfBirth: DEFAULT_DATE_OF_BIRTH, gender: DEFAULT_GENDER, neutered: DEFAULT_NEUTERED, description: DEFAULT_DESCRIPTION, uuid: DEFAULT_UUID);
  }

  group('Dog - default tests', () {
    test('create dog', (){
      Dog dog = new Dog();
      expect(dog, isNot(null));
    });

    test('equals: null should return false', (){
      Dog dog = createStaticDog();
      bool isSame = dog == null;
      expect(isSame, false);
    });

    test('equals: string with same uuid should return false', (){
      Dog dog = createStaticDog();
      String sameUUIDString = DEFAULT_UUID;
      bool isSame = dog == sameUUIDString;
      expect(isSame, false);
    });

    test('equals: dog with other uuid should return false', (){
      Dog dog = createStaticDog();
      Dog anotherDog = Dog(uuid: '2');
      bool isSame = dog == anotherDog;
      expect(isSame, false);
    });

    test('equals: dog with same uuid should return true', (){
      Dog dog = createStaticDog();
      Dog anotherDog = Dog(uuid: DEFAULT_UUID);
      bool isSame = dog == anotherDog;
      expect(isSame, true);
    });

    test('equals: same dog should return true', (){
      Dog dog = createStaticDog();
      bool isSame = dog == dog;
      expect(isSame, true);
    });

    test('hash: different dogs with different uuid should return false', (){
      Dog dog = createStaticDog();
      Dog otherDog = Dog(uuid: "2");
      bool isSame = dog.hashCode == otherDog.hashCode;
      expect(isSame, false);
    });

    test('hash: different dogs with same uuid should return true', (){
      Dog dog = createStaticDog();
      Dog otherDog = Dog(uuid: DEFAULT_UUID);
      bool isSame = dog.hashCode == otherDog.hashCode;
      expect(isSame, true);
    });

    test('hash: same dog should return true', (){
      Dog dog = createStaticDog();
      bool isSame = dog.hashCode == dog.hashCode;
      expect(isSame, true);
    });
  });

  group('Dog - getters', () {
    test('getName returns actual name', () {
      Dog dog = createStaticDog();
      var name = dog.getName();
      expect(name, DEFAULT_NAME);
    });

    test('getBreed returns actual breed', () {
      Dog dog = createStaticDog();
      var breed = dog.getBreed();
      expect(breed, DEFAULT_BREED);
    });

    test('getDateOfBirth returns actual date of birth', () {
      Dog dog = createStaticDog();
      var dateofbirth = dog.getDateOfBirth();
      expect(dateofbirth, DEFAULT_DATE_OF_BIRTH);
    });

    test('getGender returns actual gender', () {
      Dog dog = createStaticDog();
      var gender = dog.getGender();
      expect(gender, DEFAULT_GENDER);
    });

    test('getNeutured returns actual neutured', () {
      Dog dog = createStaticDog();
      var neutured = dog.getNeutered();
      expect(neutured, 'No');
    });

    test('getNeutured returns yes on true', () {
      Dog dog = createStaticDog();
      dog.setNeutered(true);
      expect(dog.getNeutered(), 'Yes');
    });

    test('getNeutured returns no on false', () {
      Dog dog = createStaticDog();
      dog.setNeutered(false);
      expect(dog.getNeutered(), 'No');
    });

    test('getDesc returns actual desc', () {
      Dog dog = createStaticDog();
      var description = dog.getDescription();
      expect(description, DEFAULT_DESCRIPTION);
    });

    test('getUUID returns actual UUID', () {
      Dog dog = createStaticDog();
      var UUID = dog.getUUID();
      expect(UUID, DEFAULT_UUID);
    });
  });

  group('Dog - setters', () {
    test('setName sets new name', () {
      Dog dog = createStaticDog();
      var name = dog.getName();
      dog.setName('anotherName');
      bool changed = name == dog.getName();
      expect(changed, false);
      expect(dog.getName(), 'anotherName');
    });

    test('setName does not set new name on null', () {
      Dog dog = createStaticDog();
      var name = dog.getName();
      dog.setName(null);
      bool notChanged = name == dog.getName();
      expect(notChanged, true);
      expect(dog.getName(), name);
    });

    test('setName does not set new name on empty or only spaces', () {
      Dog dog = createStaticDog();
      var name = dog.getName();
      dog.setName('');
      bool notChanged = name == dog.getName();
      expect(notChanged, true);
      expect(dog.getName(), name);

      dog.setName('      ');
      notChanged = name == dog.getName();
      expect(notChanged, true);
      expect(dog.getName(), name);
    });

    test('setName removes spaces on new name', () {
      Dog dog = createStaticDog();
      var name = dog.getName();
      dog.setName('  user    ');
      bool changed = !(name == dog.getName());
      expect(changed, true);
      expect(dog.getName(), 'user');
    });

    test('setGender sets new gender', () {
      Dog dog = createStaticDog();
      var gender = dog.getGender();
      dog.setGender('anotherGender');
      bool changed = !(gender == dog.getGender());
      expect(changed, true);
      expect(dog.getGender(), 'anotherGender');
    });

    test('setGender does not set gender on null', () {
      Dog dog = createStaticDog();
      var gender = dog.getGender();
      dog.setGender(null);
      bool notChanged = gender == dog.getGender();
      expect(notChanged, true);
      expect(dog.getGender(), gender);
    });

    test('setGender does not set gender on empty or only spaces', () {
      Dog dog = createStaticDog();
      var gender = dog.getGender();
      dog.setGender('');
      bool notChanged = gender == dog.getGender();
      expect(notChanged, true);
      expect(dog.getGender(), gender);
      dog.setGender('     ');
      notChanged = gender == dog.getGender();
      expect(notChanged, true);
      expect(dog.getGender(), gender);
    });

    test('setGender removes spaces on new gender', () {
      Dog dog = createStaticDog();
      var gender = dog.getGender();
      dog.setGender('  gender    ');
      bool changed = !(gender == dog.getGender());
      expect(changed, true);
      expect(dog.getGender(), 'gender');
    });

    test('setBreed sets new breed', () {
      Dog dog = createStaticDog();
      var breed = dog.getBreed();
      dog.setBreed('newbreed');
      bool changed = !(breed == dog.getBreed());
      expect(changed, true);
      expect(dog.getBreed(), 'newbreed');
    });

    test('setBreed does not set breed on null', () {
      Dog dog = createStaticDog();
      var breed = dog.getBreed();
      dog.setBreed(null);
      bool notChanged = breed == dog.getBreed();
      expect(notChanged, true);
      expect(dog.getBreed(), breed);
    });

    test('setBreed does not set breed on empty or only spaces', () {
      Dog dog = createStaticDog();
      var breed = dog.getBreed();
      dog.setBreed("");
      bool notChanged = breed == dog.getBreed();
      expect(notChanged, true);
      expect(dog.getBreed(), breed);
      dog.setBreed("     ");
      notChanged = breed == dog.getBreed();
      expect(notChanged, true);
      expect(dog.getBreed(), breed);
    });

    test('setBreed removes spaces on new breed', () {
      Dog dog = createStaticDog();
      var breed = dog.getBreed();
      dog.setBreed("    newbreed  ");
      bool changed = !(breed == dog.getBreed());
      expect(changed, true);
      expect(dog.getBreed(), 'newbreed');
    });

    test('setDateOfBirth sets new date of birth', () {
      Dog dog = createStaticDog();
      var dateofbirth = dog.getDateOfBirth();
      dog.setDateOfBirth('2020-01-02');
      bool changed = !(dateofbirth == dog.getDateOfBirth());
      expect(changed, true);
      expect(dog.getDateOfBirth(), '2020-01-02');
    });

    test('setDateOfBirth does not set new date of birth on null', () {
      Dog dog = createStaticDog();
      var dateofbirth = dog.getDateOfBirth();
      dog.setDateOfBirth(null);
      bool notChanged = dateofbirth == dog.getDateOfBirth();
      expect(notChanged, true);
      expect(dog.getDateOfBirth(), dateofbirth);
    });

    test('setDateOfBirth does not set new date of birth on empty or only spaces', () {
      Dog dog = createStaticDog();
      var dateofbirth = dog.getDateOfBirth();
      dog.setDateOfBirth("");
      bool notChanged = dateofbirth == dog.getDateOfBirth();
      expect(notChanged, true);
      dog.setDateOfBirth("    ");
      notChanged = dateofbirth == dog.getDateOfBirth();
      expect(notChanged, true);
      expect(dog.getDateOfBirth(), dateofbirth);
    });

    test('setDateOfBirth removes spaces', () {
      Dog dog = createStaticDog();
      var dateofbirth = dog.getDateOfBirth();
      dog.setDateOfBirth("   2020-02-02  ");
      bool changed = !(dateofbirth == dog.getDateOfBirth());
      expect(changed, true);
      expect(dog.getDateOfBirth(), '2020-02-02');
    });

    test('setNeutured sets new neutuered', () {
      Dog dog = createStaticDog();
      var neut = dog.getNeutered();
      dog.setNeutered(true);
      bool changed = !(neut == dog.getNeutered());
      expect(changed, true);
      expect(dog.getNeutered(), 'Yes');
    });

    test('setNeutured does not set new neutered on null', () {
      Dog dog = createStaticDog();
      var neut = dog.getNeutered();
      dog.setNeutered(null);
      bool notChanged = neut == dog.getNeutered();
      expect(notChanged, true);
      expect(dog.getNeutered(), neut);
    });

    test('setDescription sets new desc', () {
      Dog dog = createStaticDog();
      var desc = dog.getDescription();
      dog.setDescription("newdesc");
      bool changed = !(desc == dog.getDescription());
      expect(changed, true);
      expect(dog.getDescription(), 'newdesc');
    });

    test('setDescription does not set new desc on null', () {
      Dog dog = createStaticDog();
      var desc = dog.getDescription();
      dog.setDescription(null);
      bool notChanged = desc == dog.getDescription();
      expect(notChanged, true);
      expect(dog.getDescription(), desc);
    });

    test('setDescription does not set new desc on empty or only spaces', () {
      Dog dog = createStaticDog();
      var desc = dog.getDescription();
      dog.setDescription("");
      bool notChanged = desc == dog.getDescription();
      expect(notChanged, true);
      expect(dog.getDescription(), desc);

      dog.setDescription("    ");
      notChanged = desc == dog.getDescription();
      expect(notChanged, true);
      expect(dog.getDescription(), desc);
    });

    test('setDescription removes spaces', () {
      Dog dog = createStaticDog();
      var desc = dog.getDescription();
      dog.setDescription("  newdesc ");
      bool changed = !(desc == dog.getDescription());
      expect(changed, true);
      expect(dog.getDescription(), 'newdesc');
    });
  });
}