import 'dart:convert';
import 'dart:io';

import 'package:dog_prototype/elements/CustomWebView.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;


class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //auth change user stream
  Stream<FirebaseUser> get user {
    return _auth.onAuthStateChanged.map((event) {
      return event;
    });
  }

  Future<User> createUserModel(Future<IdTokenResult> token) async{
    try{
      String t = await token.then((value) => value.token);

      final response = await http.get('https://dogsonfire.herokuapp.com/users?uid=${await _auth.currentUser().then((value) => value.uid)}',headers: {
        'Authorization': 'Bearer $t',
      });

      if(response.statusCode == 200){
        return User.fromJson(json.decode(response.body));
      }else{
        print(response.statusCode);
        print(response.body);
        return null;
      }
    }catch(e){
      print(e);
      return null;
    }
  }

  //sign in with email and password String email, String password
  Future signInWithEmailAndPassword(String email, String password) async{
    try{
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);

      if(result == null){
        return null;
      }

      return User();//TODO
    }catch(e){
      print(e);
      return null;
    }
  }

  //sign in with facebook
  Future signInWithFacebook(BuildContext context) async{
    String clientID = '340936393545904';
    String url = 'https://www.facebook.com/connect/login_success.html';
    https://www.facebook.com/dialog/oauth?client_id=340936393545904&redirect_uri=https://www.facebook.com/connect/login_success.html&response_type=token&scope=email,public_profile
    try{
      String result = await Navigator.push(context, MaterialPageRoute(
        builder: (context) => CustomWebView(
          selectedUrl: 'https://www.facebook.com/dialog/oauth?client_id=$clientID&redirect_uri=$url&response_type=token&scope=email,public_profile,'),
        maintainState: true
        ),
      );

      if(result != null){
        _signInToFBWithFirebase(result);
      }
    }catch(e){

    }
  }

  _signInToFBWithFirebase(String result)async{
    try{
      final facebookAuthCred = FacebookAuthProvider.getCredential(accessToken:result);
      if(facebookAuthCred != null){
        final res = await _auth.signInWithCredential(facebookAuthCred);
      }else{
        print('something went wrong with facebook log in');
      }
    }catch(e){
      print(e);
    }
  }

  addInformationToDatabase(String email, String username, String dateOfBirth, String gender) async{
    try{
      final http.Response response = await http.post( //register to database
          'https://dogsonfire.herokuapp.com/users/register',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization' : 'Bearer ${await _auth.currentUser().then((value) => value.getIdToken().then((value) => value.token))}'
          },
          body: jsonEncode(<String,String>{
            "username": username,
            "email": email,
            "dateOfBirth": dateOfBirth,
            "gender": gender,
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print("Added information to database. " + response.statusCode.toString());
        return true;
      }else{ //Something went wrong
        print("Something went wrong with adding information to database. " + response.statusCode.toString());
        print(response.body);
        return null;
      }
    }catch(e){
      print(e);
      return null;
    }
  }

  isRegisteredToDatabase() async{
    bool isRegistered = false;
    String token = await _auth.currentUser().then((value) => value.getIdToken().then((value) => value.token));
    try{
      final http.Response response = await http.post( //register to database
          'https://dogsonfire.herokuapp.com/users/authenticate',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization' : 'Bearer $token'
          },
      );

      if(response.statusCode==200){
        isRegistered = true;
      }else{
        isRegistered = false;
        print(response.statusCode);
        print(response.body);
      }
      return isRegistered;
    }catch(e){
      print(e);
    }
  }

  //register with email and password
  Future<User> registerWithEmailAndPassword(String username, String email, String dateOfBirth, String gender, String password) async{
    try{
      dynamic result = await _registerToDatabase(username, email, dateOfBirth, gender, password);
      print("this was the result: " + result);
      if(result != null){
        print('in here');
        return User(); //TODO
      }else{
        return null;
      }
    }catch(e){
      print(e);
      return null;
    }
  }

  _registerToDatabase(String username, String email, String dateOfBirth, String gender, String password)async{
    try {
      final http.Response response = await http.post( //register to database
          'https://dogsonfire.herokuapp.com/users/register',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String,String>{
            "username": username,
            "email": email,
            "dateOfBirth": dateOfBirth,
            "gender": gender,
            "password":password
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print(response.statusCode);
        await signInWithEmailAndPassword(email, password);
      }else{ //Something went wrong
        print(response.statusCode);
        print(response.body);
      }
    } catch (e) {
      print("catch: " + e.message);
    }
  }

  //sign out
  Future signOut() async{
    try{
      _auth.signOut();
      return Future.delayed(Duration.zero);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future changePassword(String password) async{
    try{
      FirebaseUser user = await _auth.currentUser();
      user.updatePassword(password);
      signOut();
      return true;
    }catch(e){
      print(e);
      return null;
    }
  }

  //get token
  Future<String> getToken() async{
    if(_auth.currentUser() != null){
      FirebaseUser user = await _auth.currentUser();
      IdTokenResult token = await user.getIdToken();
      return token.token;
    }
    return null;
  }

  //GET CURRENT USER
  Future<FirebaseUser> getCurrentFirebaseUser() async{
    return await _auth.currentUser();
  }

}