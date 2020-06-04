import 'package:dog_prototype/pages/FacebookForm.dart';
import 'package:dog_prototype/pages/placeHolderHome.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'loaders/DefaultLoader.dart';
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
          print('Stream got new firebase user event!');
          final bool isLoggedIn = snapshot.hasData;
          print('isLoggedIn is now: $isLoggedIn');
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
    print('Inside Redirect, calling method: _isRegisteredToDatabase');
    return FutureBuilder(
      future: _isRegisteredToDatabase(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          if(snapshot.data == true){
            print('Inside futurebuilder of Redirect class, answer gotten from _isRegToDatabase, answer was: ${snapshot.data}');
            print('Calling AuthService method: createUserModel');
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
    print('Inside: _isRegisteredToDatabase');
    _registeredToDatabase = await AuthService().isRegisteredToDatabase();
    print('AuthService method: isRegisteredToDatabase returned with: $_registeredToDatabase');
    return _registeredToDatabase;
  }
}
