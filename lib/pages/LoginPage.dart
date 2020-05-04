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

class LoginPageState extends State<LoginP>{

  final _formkey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController(); //TODO: FINNS DET NÅGOT SÄTT ATT ANVÄNDA EN CONTROLLER FÖR FLER TEXTFIELDS?
  bool wrongCredent = false;

  @override
  Widget build(BuildContext context){
    //scaffold is a structure
    return new Scaffold(
      body: Form(
          key: _formkey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(50, 170, 15, 15), //TODO: TESTA HARDKODAD PADDING MED ANDRA VERSIONER
            children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: new AssetImage('assets/loginpicture.jpg'),
                      height: 100.0,
                    ),
                    TextField(
                      decoration: new InputDecoration(
                        hintText: "Username* ",
                      ),
                      keyboardType: TextInputType.text,
                      controller: usernameController,
                    ),
                    TextField(
                      decoration: new InputDecoration(
                        hintText: "Password* ",
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      controller: passwordController,
                    ),
                    MaterialButton(
                      padding: EdgeInsets.all(10),
                      height: 40.0,
                      minWidth: 100.0,
                      color: Colors.teal,
                      textColor: Colors.white,
                      child: new Text("Sign in"),
                      onPressed: () {
                        login();
                      },
                      splashColor: Colors.redAccent, //färgen när man trycker på knappen
                    ),
                    Text(
                        "OR",
                    ),
                    MaterialButton(
                      height: 40.0,
                      minWidth: 100.0,
                      color: Colors.teal,
                      textColor: Colors.white,
                      child: new Text("Register new user"),
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute<Null>(
                                builder: (BuildContext context) {
                                  return new Signup();
                                }));
                      },
                      splashColor: Colors.redAccent, //färgen när man trycker på knappen
                    ),
                    Text(
                        "Forgot your password? Retrieve it here"
                    ),
                    TextField(
                      decoration: InputDecoration(
                        errorText: wrongCredent ? 'Wrong username or password' : null,
                      ),
                    )
                  ],
                )
            ],
          )
      )
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => PlaceHolderApp()));
        }else{
          setState((){wrongCredent=true;});
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
}