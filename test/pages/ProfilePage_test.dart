
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockUser extends Mock implements User{
  String username;
  String desc;
  List<dynamic> dogs;
  MockUser(){this.username = 'username'; this.desc = 'a description'; this.dogs = [Dog()];}
}

class MockDog extends Mock implements Dog{
  String name;
  MockDog(){this.name = 'dogname';}
}

void main() {
}
