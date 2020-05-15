import 'package:dog_prototype/pages/placeHolderHome.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/StartPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var isLoggedIn = prefs.getBool('isLoggedIn');
  print(isLoggedIn);
  runApp(MaterialApp(home: isLoggedIn == null || isLoggedIn == false ? StartPage() : PlaceHolderApp()));
}
