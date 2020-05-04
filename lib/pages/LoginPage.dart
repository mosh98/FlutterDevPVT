import 'dart:convert';

import 'package:flutter/material.dart';
import 'placeHolderHome.dart';
import 'signup.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    //we customize our own build instead of the one inside Statelesswidget
    return new MaterialApp(
        home: new LoginP(),//home screen
        theme: new ThemeData( //colour
            primarySwatch: Colors.blue
        )
    );
  }
}

class LoginP extends StatefulWidget{
  //stateful since we want to add stateful widgets
  @override //=> lambda
  State createState() => new LoginPageState(); //creates new loginpagestate
}

class LoginPageState extends State<LoginP> with SingleTickerProviderStateMixin{

  final _formkey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController(); //TODO: FINNS DET NÅGOT SÄTT ATT ANVÄNDA EN CONTROLLER FÖR FLER TEXTFIELDS?

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
                        Navigator.of(context).push(
                            MaterialPageRoute<Null>(
                                builder: (BuildContext context) {
                                  _getAuthenticationToken(usernameController.text, passwordController.text);
                                  return new PlaceHolderApp(); //todo: should check first
                                }));
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
                    )
                  ],
                )
            ],
          )
      )
    );
  }

  Future<String> _getAuthenticationToken(String username, String password) async {
    final http.Response response = await http.post(
      'https://pvt-dogpark.herokuapp.com/authenticate',
      headers:<String, String>{
        'Content-Type' : 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String,String>{
        'username':username,
        'password':password
      })
    );

    if(response.statusCode == 200){
      Map<String, dynamic> token = json.decode(response.body);
      print(token);
    }else{
      print('wrong');
    }
  }
}