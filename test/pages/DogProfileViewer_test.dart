
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/pages/DogProfileViewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
import 'package:mockito/mockito.dart';

class MockStorageProvider extends Mock implements StorageProvider{
  @override
  Future<String> getProfileImageDog(Dog dog) async{
    return null;
  }
}

void main(){

  const String DEFAULT_DOGNAME = 'nameOne';
  const String DEFAULT_DOG_BREED = 'breed';
  const String DEFAULT_DOG_DATE_OF_BIRTH = '2020-01-01';
  const bool DEFAULT_NEUTERED = false;
  const String DEFAULT_GENDER = 'MALE';
  const String DEFAULT_DESCRIPTION = 'decs';
  const String DEFAULT_DOGONE_ID = '1';
  Dog fakeDog = Dog(name: DEFAULT_DOGNAME, breed: DEFAULT_DOG_BREED, dateOfBirth: DEFAULT_DOG_DATE_OF_BIRTH, neutered: DEFAULT_NEUTERED, gender: DEFAULT_GENDER, description: DEFAULT_DESCRIPTION, uuid:DEFAULT_DOGONE_ID);

  MockStorageProvider storageProvider = MockStorageProvider();
  
  DogProfileViewer dogProfileViewer = DogProfileViewer(storageProvider: storageProvider,dog: fakeDog,);

  Finder nameField = find.byKey(Key('name'));
  Finder breedField = find.byKey(Key('breed'));
  Finder dateOfBirthField = find.byKey(Key('dateofbirth'));
  Finder neuteredField = find.byKey(Key('neutered'));
  Finder genderField = find.byKey(Key('gender'));
  Finder descField = find.byKey(Key('description'));
  
  Widget page = MaterialApp(
    home: Scaffold(
      body: dogProfileViewer,
    ),
  );
  
  group('defaults', () { 
    testWidgets('Rendering page', (tester)async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();
      expect(find.byType(DogProfileViewer),findsOneWidget);
    });

    testWidgets('Finding widgets', (tester)async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      expect(nameField,findsOneWidget);
      expect(breedField,findsOneWidget);
      expect(dateOfBirthField,findsOneWidget);
      expect(neuteredField,findsOneWidget); //SINCE DOG IS A MALE
      expect(genderField,findsOneWidget);
      expect(descField,findsOneWidget);
    });

    testWidgets('Page displays correct data', (tester)async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      expect(find.text(DEFAULT_DOGNAME),findsOneWidget);
      expect(find.text(DEFAULT_DOG_BREED),findsOneWidget);
      expect(find.text(DEFAULT_DOG_DATE_OF_BIRTH),findsOneWidget);
      expect(find.text('No'),findsOneWidget); //SINCE DOG IS A MALE, neutered
      expect(find.text(DEFAULT_GENDER),findsOneWidget);
      expect(find.text(DEFAULT_DESCRIPTION),findsOneWidget);
    });
  });
}