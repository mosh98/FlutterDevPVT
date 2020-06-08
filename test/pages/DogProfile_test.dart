
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/pages/DogProfile.dart';
import 'package:dog_prototype/services/HttpProvider.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';


class MockHttpProvider extends Mock implements HttpProvider{
  @override
  Future<bool> setBreed(Dog dog, String breed) async{
    return true;
  }

  @override
  Future<bool> setDateOfBirthDog(Dog dog, String dateOfBirth) async{
    return true;
  }

  @override
  Future<bool> updateNeutered(Dog dog, bool neut) async{
    return true;
  }

  @override
  Future<bool> setDescriptionDog(Dog dog, String desc) async{
    return true;
  }
}
class MockStorageProvider extends Mock implements StorageProvider{}
class MockNavigationObserver extends Mock implements NavigatorObserver{}

void main(){

  final MockNavigationObserver mockObserver = MockNavigationObserver();
  final MockStorageProvider mockStorageProvider = MockStorageProvider();
  final MockHttpProvider mockHttpProvider = MockHttpProvider();

  const String DEFAULT_NAME = 'name';
  const String DEFAULT_BREED = 'breed';
  const String DEFAULT_DATE_OF_BIRTH = '2020-01-01';
  const String DEFAULT_GENDER = 'MALE';
  const bool DEFAULT_NEUTERED = false;
  const String DEFAULT_DESCRIPTION = 'desc';
  const String DEFAULT_UUID = '1';
  final Dog fakeDog = Dog(name: DEFAULT_NAME, breed: DEFAULT_BREED, dateOfBirth: DEFAULT_DATE_OF_BIRTH, gender: DEFAULT_GENDER, neutered: DEFAULT_NEUTERED, description: DEFAULT_DESCRIPTION, uuid: DEFAULT_UUID);

  final DogProfile dogProfile = DogProfile(dog: fakeDog, storageProvider: mockStorageProvider, httpProvider: mockHttpProvider,);

  final Finder nameField = find.byKey(Key('name'));
  final Finder breedField = find.byKey(Key('breed'));
  final Finder dateOfBirthField = find.byKey(Key('dateofbirth'));
  final Finder neuteredField = find.byKey(Key('neutered'));
  final Finder genderField = find.byKey(Key('gender'));
  final Finder descField = find.byKey((Key('description')));
  final Finder descEditIcon = find.byKey(Key('editdesc'));
  final Finder picture = find.byKey(Key('picture'));

  final Widget page = MaterialApp(
      home:Scaffold(
        body: dogProfile,
      ),
      navigatorObservers: [mockObserver],
  );

  group('defaults', () {
    testWidgets('Rendering page', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();
      expect(find.byType(DogProfile), findsOneWidget);
    });

    testWidgets('Find widgets', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();
      expect(nameField, findsOneWidget);
      expect(breedField, findsOneWidget);
      expect(dateOfBirthField, findsOneWidget);
      expect(neuteredField, findsOneWidget);
      expect(genderField, findsOneWidget);
      expect(descField, findsOneWidget);
      expect(descEditIcon, findsOneWidget);
      expect(picture, findsOneWidget);
    });

    testWidgets('Find widget neutered only on male dog', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();
      expect(neuteredField, findsOneWidget);
      fakeDog.setGender('FEMALE');
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();
      expect(find.text('neutered'), findsNothing);
      fakeDog.setGender('MALE');
    });

    testWidgets('Dog profile displays all information correctly', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      expect(find.text(DEFAULT_NAME), findsOneWidget);
      expect(find.text(DEFAULT_BREED), findsOneWidget);
      expect(find.text(DEFAULT_DATE_OF_BIRTH), findsOneWidget);
      expect(find.text('No'), findsOneWidget); //DEFAULT_NEUT IS FALSE AND SO THIS FIELD BECOMES 'NO'.
      expect(find.text(DEFAULT_GENDER), findsOneWidget);
      expect(find.text(DEFAULT_DESCRIPTION), findsOneWidget);
    });
  });

  group('Testing - Edit Breed Dialog', () {

    Finder editBreedDialog = find.byKey(Key('editbreeddialog'));
    Finder breedTextField = find.byKey(Key('breedtextfield'));
    Finder submitButton = find.byKey(Key('submit'));
    Finder cancelButton = find.byKey(Key('cancel'));

    testWidgets('Finding widgets of dialog: Edit breed', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      await tester.tap(breedField);
      await tester.pumpAndSettle();

      expect(editBreedDialog, findsOneWidget);
      expect(breedTextField, findsOneWidget);
      expect(submitButton, findsOneWidget);
      expect(cancelButton, findsOneWidget);
    });

    testWidgets('Edit breed actually change breed', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      await tester.tap(breedField);
      await tester.pumpAndSettle();

      await tester.enterText(editBreedDialog, 'newbreed');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('newbreed'),findsOneWidget);
    });

    testWidgets('Cancel button actually closes dialog', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      verify(mockObserver.didPush(any, any));

      await tester.tap(breedField);
      await tester.pumpAndSettle();

      verify(mockObserver.didPop(any, any));

      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      expect(find.byType(DogProfile),findsOneWidget);
    });
  });

  group('Testing - Edit Date Of Birth Field', () {

    Finder dateOfBirthPicker = find.byKey(Key('dateofbirthpicker'));

    testWidgets('Finding widgets', (tester)async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      await tester.tap(dateOfBirthField);
      await tester.pumpAndSettle();

      expect(dateOfBirthPicker, findsOneWidget);
    });

    testWidgets('Changing date of birth actually changes date of birth', (tester)async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();;

      await tester.tap(dateOfBirthField);
      await tester.pumpAndSettle();

      await tester.drag(dateOfBirthPicker, Offset(0.0,70.0));
      await tester.tap(find.text('Name:'));
      verify(mockObserver.didPop(any, any));
      await tester.pumpAndSettle();

      expect(dateOfBirthPicker,findsNothing);
      expect(find.byType(DogProfile),findsOneWidget);
      expect(find.text("2020-04-08"),findsOneWidget); //new chosen date from above
    });
  });

  group('Testing - Neutered Field', () {

    Finder dropDownButton = find.byKey(Key('dropdownneutered'));
    Finder yesButton = find.byKey(Key('Yes'));
    Finder noButton = find.byKey(Key('No'));

    testWidgets('Finding widgets of dialog: Edit Neutured', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      expect(dropDownButton, findsOneWidget);

      await tester.tap(dropDownButton);

      expect(yesButton, findsOneWidget);
      expect(noButton, findsOneWidget);
    });

    testWidgets('Changing neutered actually changes neutered', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      await tester.tap(dropDownButton);

      await tester.tap(noButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Name:'));
      await tester.pumpAndSettle();

      expect(find.byType(DogProfile),findsOneWidget);
      expect(noButton,findsOneWidget);
    });
  });

  group('Testing - Gender Field', () {

    Finder dropDownButton = find.byKey(Key('dropdowngender'));
    Finder maleButton = find.byKey(Key('MALE'));
    Finder femaleButton = find.byKey(Key('FEMALE'));

    testWidgets('Finding widgets of dialog: Edit Gender', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      expect(dropDownButton, findsOneWidget);

      await tester.tap(dropDownButton);

      expect(maleButton, findsOneWidget);
      expect(femaleButton, findsOneWidget);
    });

    testWidgets('Changing gender actually changes gender', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      await tester.tap(dropDownButton);

      await tester.tap(maleButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Name:'));
      await tester.pumpAndSettle();

      expect(find.byType(DogProfile),findsOneWidget);
      expect(maleButton,findsOneWidget);
    });
  });

  group('Testing - Edit description', () {
    Finder textField = find.byKey(Key('textfielddesc'));
    Finder doneButton = find.byKey(Key('done'));
    Finder cancelButton = find.byKey(Key('cancel'));

    testWidgets('Finding widgets of dialog: Edit Gender', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      await tester.tap(descEditIcon);
      await tester.pumpAndSettle();

      expect(textField, findsOneWidget);
      expect(doneButton, findsOneWidget);
      expect(cancelButton, findsOneWidget);
    });

    testWidgets('edit description actually edits description', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      await tester.tap(descEditIcon);
      await tester.pumpAndSettle();

      await tester.enterText(textField, 'newDesc');
      await tester.tap(doneButton);
      await tester.pumpAndSettle();

      expect(find.text('newDesc'), findsOneWidget);
    });

    testWidgets('cancel button actually exits dialog', (tester) async{
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      await tester.tap(descEditIcon);
      await tester.pumpAndSettle();

      verify(mockObserver.didPush(any, any));

      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      verify(mockObserver.didPop(any, any));

      expect(find.byType(DogProfile), findsOneWidget);
    });
  });

}