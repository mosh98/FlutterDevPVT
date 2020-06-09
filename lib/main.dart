import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/FacebookForm.dart';
import 'package:dog_prototype/pages/placeHolderHome.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/services/HttpProvider.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
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
  bool hasInit = false;
  StorageProvider storageProvider;
  HttpProvider httpProvider;
  AuthService authService;
  User user;

  @override
  void initState() {
    //_init();
    super.initState();
  }

  _init() async{
    authService = await AuthService();
    user = await authService.createUserModel(AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken()));
    storageProvider = await StorageProvider(user:user);
    httpProvider = await HttpProvider.instance(userToken: await authService.getToken());
    if(authService != null && user != null && storageProvider != null && httpProvider != null){
      setState(() {
        hasInit = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _isRegisteredToDatabase(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          if(snapshot.data == true){
            if(hasInit){
              return PlaceHolderApp(user:user,storageProvider: storageProvider, httpProvider: httpProvider, authService: authService,);
            }else{
              _init();
            }
            return DefaultLoader();
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
    _registeredToDatabase = await AuthService().isRegisteredToDatabase();
    return _registeredToDatabase;
  }
}
