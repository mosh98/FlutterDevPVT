import 'dart:convert';

import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../placeHolderHome.dart';
import 'signup.dart';
import 'package:http/http.dart' as http;

class UserNameValidator{
  static String validate(String input){
    return input.isEmpty || input.trim().isEmpty ? 'Username cant be empty' : null;
  }
}

class PasswordValidator{
  static String validate(String input){
    return input.isEmpty || input.trim().isEmpty ? 'Password cant be empty' : null;
  }
}

class LoginPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return new MaterialApp(
        home: new LoginP(),//home screen
        theme: new ThemeData( //colour
            primarySwatch: Colors.blue
        )
    );
  }
}

class LoginP extends StatefulWidget{

  @override
  State createState() => new LoginPageState();

}

class LoginPageState extends State<LoginP> {

  final _formkey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool wrongCredent = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
          key: _formkey,
          child: _isLoading ? Center(child:DefaultLoader()) : ListView(
            padding: const EdgeInsets.fromLTRB(25, 170, 25, 15),
            children: <Widget>[
              headerSection(),
              textFieldSection(),
              buttonSection(),
            ],
          ),
        )
    );
  }

  Container headerSection() {
    return Container(
      child:Image(
        image: new AssetImage('assets/loginpicture.jpg'),
        height: 100.0,
      ),
    );
  }

  Container textFieldSection(){
    return Container(
        padding: const EdgeInsets.only(top: 25),
        child: Column(
          children: <Widget>[
            TextFormField(
              key: Key('username'),//REFERENCE FOR TEXTFIELD, USED FOR TESTING
              decoration: new InputDecoration(
                hintText: "Username* ",
                icon: Icon(Icons.person),
              ),
              validator: UserNameValidator.validate,
              keyboardType: TextInputType.text,
              controller: usernameController,
            ),
            TextFormField(
              key: Key('password'),//REFERENCE FOR TEXTFIELD, USED FOR TESTING
              decoration: new InputDecoration(
                hintText: "Password* ",
                icon: Icon(Icons.lock),
              ),
              validator: PasswordValidator.validate,
              obscureText: true,
              keyboardType: TextInputType.text,
              controller: passwordController,
            ),
            _isWrongCredent(),
          ],
        ),
    );
  }

  Container buttonSection(){
    return Container(
          padding: const EdgeInsets.only(top:20),
          child: Column(
            children: <Widget>[
              MaterialButton(
                key: Key("signIn"), //REFERENCE FOR BUTTON, USED FOR TESTING
                height: 40.0,
                minWidth: 250.0,
                color: Colors.black54,
                textColor: Colors.white,
                child: new Text("Sign in"),
                onPressed: () {
                  setState((){_isLoading = true;});
                  _firebaseLogin(usernameController.text, passwordController.text);
                  login(usernameController.text, passwordController.text);
                },
                splashColor: Colors.redAccent,
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              ),
              Text(
                "OR",
              ),
              MaterialButton(
                height: 40.0,
                minWidth: 250.0,
                color: Colors.black54,
                textColor: Colors.white,
                child: new Text("Register new user"),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute<Null>(
                          builder: (BuildContext context) {
                            return new Signup();
                          }));
                },
                splashColor: Colors.redAccent,
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              ),
              FlatButton(
                child: Text("Forgot your password? Retrieve it here."),
                onPressed: (){print('test');},
              )
            ],
          ),
    );
  }

  Future<void> login(String username, String password) async {
    final formState = _formkey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        final http.Response response = await http.post('https://redesigned-backend.herokuapp.com/user/login?username=$username&password=$password');

        if(response.statusCode==200){
          _setPreferences(true, username);
          setState((){
            _isLoading = false;
          });
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => PlaceHolderApp()), (Route<dynamic> route) => false);
        }else{
          setState((){
            wrongCredent = true;
            _isLoading = false;
          });
        }
      } catch (e) {
        print(e.message);
      }
    }else{
      setState((){
        _isLoading = false;
      });
    }
  }

  Future<void> _setPreferences(bool loggedIn, String username) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', loggedIn);
    await prefs.setString('username', username);
  }

  Widget _isWrongCredent(){
    return wrongCredent ? Text('Wrong username or password',style: TextStyle(color:Colors.red),) : Text('');
  }

  /**
   * EVERYTHING AFTER THIS IS TEMPORARY CODE TO TEST FIREBASE, REMOVE IF WE DECIDE WITH SOMETHING ELSE
   */
  final AuthService _auth = AuthService();
  bool _firebaseLogin(String email, String password){
    dynamic result = _auth.signInWithEmailAndPassword(email, password);
    if(result == null){
      setState((){
        //set error message wrong username or password
        _isLoading = false;
      });
    }
    print(result);
  }
}