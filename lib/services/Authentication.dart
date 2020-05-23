import 'dart:convert';
import 'dart:io';

import 'package:dog_prototype/models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:http/http.dart' as http;



class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // auth change user stream
  Stream<FirebaseUser> get user {
    return _auth.onAuthStateChanged.map((event) {
      return event;
    });
  }

  Future<User> createUserModel(Future<IdTokenResult> token) async{
    try{
      String t = await token.then((value) => value.token);

      final response = await http.get('https://dogsonfire.herokuapp.com/user/',headers: {
        'Authorization': 'Bearer $t',
      });

      if(response.statusCode == 200){
        return User.fromJson(json.decode(response.body));
      }else{
        print(response.statusCode);
        print(response.body);
      }
    }catch(e){
      print(e);
      return null;
    }
  }

  //sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async{
    try{
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = await createUserModel(result.user.getIdToken());
      print(await result.user.getIdToken().then((value) => value.token));
      return user;
    }catch(e){
      print(e);
      return null;
    }
  }

  //register with email and password
  Future registerWithEmailAndPassword(String email, String password) async{
    try{
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    }catch(e){
      print(e);
      return null;
    }
  }

  //sign out
  Future signOut() async{
    try{
      return await _auth.signOut();
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
  Future<FirebaseUser> getCurrentUser() async{
    return await _auth.currentUser();
  }
}