import 'dart:convert';

import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/material.dart';
import 'RegisterPage.dart';

class LoginPage extends StatefulWidget{
  @override
  State createState() => new LoginPageState();

}

class LoginPageState extends State<LoginPage> {

  final AuthService _auth = AuthService();
  final _formkey = GlobalKey<FormState>();
  String email,password = "";
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
            key: Key('Email'),//REFERENCE FOR TEXTFIELD, USED FOR TESTING
            decoration: new InputDecoration(
              hintText: "Email* ",
              icon: Icon(Icons.person),
            ),
            validator: UserNameValidator.validate,
            keyboardType: TextInputType.text,
            onChanged: (emailValue){
              setState(() => email = emailValue);
            },
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
              onChanged: (passwordValue){
                setState(() => password = passwordValue);
              }
          ),
          _wrongCredentials(),
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
            onPressed: () async {
              setState(() => _isLoading = true);
              dynamic result = _firebaseLogin(email, password);
              if(result==null){
                setState(() {
                  _wrongCredentials();
                  _isLoading = false;
                });
              }
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
            child: new Text("Sign in with Facebook"),
            onPressed: () {
              _signInWithFacebook();
            },
            splashColor: Colors.redAccent,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          ),
          FlatButton(
            child: Text("Forgot your password? Retrieve it here."),
            onPressed: (){_resetPasswordDialog();},
          )
        ],
      ),
    );
  }

  _resetPasswordDialog() async{
    String email;

    await showDialog(
        context: context,
        child: SimpleDialog(
          contentPadding: EdgeInsets.all(10.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          children: [
            Container(
              child: Row(
                children: [
                  Text(
                    'E-mail:',
                    style: TextStyle(fontSize: 17),
                  ),
                  Padding(padding: EdgeInsets.only(left:10),),
                  Container(child:TextField(onChanged: (String newEmail){email = newEmail;},), width: 150,),
                  Padding(padding: EdgeInsets.only(left:25),),
                  IconButton(icon: Icon(Icons.done), onPressed: ()async{await _resetPassword(email); Navigator.of(context, rootNavigator:true).pop();})
                ],
              ),
            )
          ],
        ),
    );
  }

  _resetPassword(String email){
    AuthService().resetPasswordUsingEmail(email);
  }


  Widget _wrongCredentials(){
    return wrongCredent ? Text('Wrong username or password',style: TextStyle(color:Colors.red),) : Text('');
  }

  _firebaseLogin(String email, String password) async{
    final formState = _formkey.currentState;
    if(formState.validate()){
      formState.save();
      try{
        dynamic result = await _auth.signInWithEmailAndPassword(email, password);
        if(result == null){
          setState((){
            wrongCredent = true;
            _isLoading = false;
          });
        }
      }catch(e){
        print(e.message);
      }
    }else{
      setState((){
        _isLoading = false;
      });
    }
  }

  void _signInWithFacebook() {
    AuthService().signInWithFacebook(context);
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