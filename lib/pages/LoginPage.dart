import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'placeHolderHome.dart';
import 'signup.dart';
import 'package:http/http.dart' as http;

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
          child: _isLoading ? Center(child:CircularProgressIndicator()) : ListView(
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

  Container headerSection(){
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
                  login();
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

  Future<void> login() async {
    final formState = _formkey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        final http.Response response = await http.post(
            'https://pvt-dogpark.herokuapp.com/authenticate',
            headers:<String, String>{
              'Content-Type' : 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String,String>{
              'username':'testarigen',
              'password':'hemligare'
            }) //TODO: HÅRDKODAT NAMN OCH LÖSENORD, ÄNDRA MED .GET FRÅN TEXTFIELD CONTROLLERS.
        );

        if(response.statusCode==200){
          Map<String, dynamic> token = json.decode(response.body);
          _saveToken(token.toString());
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
    }
  }

  Future<void> _saveToken(String token) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Widget _isWrongCredent(){
    return wrongCredent ? Text('Wrong username or password',style: TextStyle(color:Colors.red),) : Text('');
  }
}

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