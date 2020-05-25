import 'dart:convert';
import 'dart:io';

import 'package:dog_prototype/pages/LoginPage.dart';
import 'package:dog_prototype/pages/ProfilePage.dart';
import 'package:dog_prototype/pages/OldPagesSavedIncaseProblem/signup.dart';
import 'package:dog_prototype/pages/placeHolderHome.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loaders/DefaultLoader.dart';
import 'models/User.dart';
import 'pages/StartPage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Wrapper(),
    );
  }
}

class Wrapper extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
  return StreamBuilder<FirebaseUser>(
    stream: AuthService().user,
    builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
      if(snapshot.connectionState == ConnectionState.active){
      final bool isLoggedIn = snapshot.hasData;
      print(isLoggedIn);
        return isLoggedIn ?
        PlaceHolderApp(futureUser: AuthService().createUserModel(snapshot.data.getIdToken()))
         :
        StartPage();
      }
    return DefaultLoader();
    },
  );
}


}
