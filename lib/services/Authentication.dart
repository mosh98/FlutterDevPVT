import 'dart:convert';
import 'dart:io';

import 'package:dog_prototype/models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

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
      print(t);

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

  //register with email and password
  Future<User> registerWithEmailAndPassword(String username, String email, String dateOfBirth, String gender, String password) async{
    try{
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      if(result != null){
        String token = await result.user.getIdToken().then((value) => value.token);
        await _registerToDatabase(username, email, dateOfBirth, gender, token, password);
        return User(); //TODO
      }else{
        return null;
      }
    }catch(e){
      print(e);
      return null;
    }
  }

  _registerToDatabase(String username, String email, String dateOfBirth, String gender, String token, String password)async{
    try {
      final http.Response response = await http.post( //register to database
          'https://dogsonfire.herokuapp.com/user/register',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String,String>{
            "username": username,
            "email": email,
            "dateOfBirth": dateOfBirth,
            "gender": gender
          })
      );

      print('inside registertodatabase'); //TODO
      if(response.statusCode==200){ // Successfully created database account
        print(response.statusCode);
        signOut();
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