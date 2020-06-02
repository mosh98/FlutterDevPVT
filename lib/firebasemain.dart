import 'dart:convert';
import 'dart:io';

import 'package:dog_prototype/pages/FacebookForm.dart';
import 'package:dog_prototype/pages/LoginPage.dart';
import 'package:dog_prototype/pages/ProfilePage.dart';
import 'package:dog_prototype/pages/OldPagesSavedIncaseProblem/signup.dart';
import 'package:dog_prototype/pages/placeHolderHome.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/services/Validator.dart';
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
        return isLoggedIn ?
        Redirect()
         :
        StartPage();
      }
    return DefaultLoader();
    },
  );
  }
}

class Redirect extends StatefulWidget {
  @override
  _RedirectState createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {

  bool _registeredToDatabase;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _isRegisteredToDatabase(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          if(snapshot.data == true){
            return PlaceHolderApp(futureUser: AuthService().createUserModel(AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken())));
            //return FacebookForm();
          }else{
            return FacebookForm();
          }
        }else if(snapshot.hasError){
          return Text('error');
        }else{
          return DefaultLoader();
        }
      },
    );
  }

  _isRegisteredToDatabase() async{
    return _registeredToDatabase = await AuthService().isRegisteredToDatabase();
  }
}
