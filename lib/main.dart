import 'package:dog_prototype/pages/placeHolderHome.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dog_prototype/pages/OldPagesSavedIncaseProblem/StartPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var isLoggedIn = prefs.getBool('isLoggedIn');
  //runApp(MaterialApp(home: StartPage()));
  runApp(MaterialApp(home: isLoggedIn == null || isLoggedIn == false ? StartPage() : PlaceHolderApp()));
}
