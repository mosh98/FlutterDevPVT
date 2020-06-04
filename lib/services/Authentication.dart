import 'dart:convert';
import 'dart:io';

import 'package:dog_prototype/elements/CustomWebView.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  //create user model
  Future<User> createUserModel(Future<IdTokenResult> token) async{
    print('Inside AuthService method: createUserModel');
    try{
      String t = await token.then((value) => value.token);

      final response = await http.get('https://dogsonfire.herokuapp.com/users?uid=${
          await _auth.currentUser().then((value) => value.uid)}',headers:<String, String>{
        'Authorization': 'Bearer $t',
        'Content-Type': 'application/json'
      });

      if(response.statusCode == 200){
        print('Response: 200 statuscode');
        return User.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      }else{
        print('Response: ${response.statusCode.toString()} statuscode');
        print(response.statusCode);
        print(response.body);
        return null;
      }
    }catch(e){
      print(e);
      return null;
    }
  }

  Future<bool> deleteAccount()async{
    String token = await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token));
    try{
      final response = await http.delete('https://dogsonfire.herokuapp.com/users', headers:{'Authorization': 'Bearer $token'});
      if(response.statusCode == 204){
        await signOut();
        print('Successfully deleted account: ' + response.statusCode.toString());
        return true;
      }
      return false;
    }catch(e){
      print(e);
      return false;
    }
  }

  //password reset with email
  resetPasswordUsingEmail(String email)async{
    try{
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    }catch(e){
     print(e);
     return null;
    }
  }

  //sign in with email and password String email, String password
  Future signInWithEmailAndPassword(String email, String password) async{
    try{
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if(result != null){
        return true;
      }
      return false;
    }catch(e){
      print(e);
      return null;
    }
  }

  //sign in with facebook
  Future signInWithFacebook(BuildContext context) async{
    String clientID = '340936393545904';
    String url = 'https://www.facebook.com/connect/login_success.html';

    try{
      String result = await Navigator.push(context, MaterialPageRoute(
        builder: (context) => CustomWebView(
          selectedUrl: 'https://www.facebook.com/dialog/oauth?client_id=$clientID&redirect_uri=$url&response_type=token&scope=email,public_profile,'),
        maintainState: true
        ),
      );

      if(result != null){
        print('Correct credentials with facebook, signing in wiht firebase..');
        _signInToFBWithFirebase(result);
      }
    }catch(e){

    }
  }

  Future _signInToFBWithFirebase(String result)async{
    try{
      final facebookAuthCred = FacebookAuthProvider.getCredential(accessToken:result);
      if(facebookAuthCred != null){
        print('Succesfully got facebook credentials, signing in..');
        final res = await _auth.signInWithCredential(facebookAuthCred);
        print('Succesfully signed in to firebase with facebook credentials, returning user..');
        return res.user;
      }else{
        print('something went wrong with facebook log in');
        return null;
      }
    }catch(e){
      print(e);
      return null;
    }
  }

  addInformationToDatabase(String username, String dateOfBirth, String gender) async{
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
            "dateOfBirth": dateOfBirth,
            "gender": gender,
            'email': await _auth.currentUser().then((value) => value.email)
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
      final http.Response response = await http.post(
          'https://dogsonfire.herokuapp.com/users/authenticate',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization' : 'Bearer $token'
          },
      );

      if(response.statusCode==200){
        isRegistered = true;
        print('Inside Authservice method: isRegisteredToDatabase, return from http was: $isRegistered');
      }else{
        isRegistered = false;
        print(response.statusCode);
        print(response.body);
      }
      print('returning $isRegistered');
      return isRegistered;
    }catch(e){
      print(e);
    }
  }


  //register with email and password
  Future<String> registerWithEmailAndPassword(String username, String email, String dateOfBirth, String gender, String password) async{
    try{

      dynamic result = await _registerToDatabase(username, email, dateOfBirth, gender, password);

      if(result != null){
        return result;
      }else{
        return null;
      }
    }catch(e){
      print(e);
      return null;
    }
  }

  Future<String> _registerToDatabase(String username, String email, String dateOfBirth, String gender, String password)async{
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

      if(response.statusCode==200){
        print(response.statusCode);
        await signInWithEmailAndPassword(email, password);
        return response.statusCode.toString();
      }else{
        print(response.statusCode);
        print(response.body);
        return json.decode(response.body)['message'];
      }
    } catch (e) {
      print("catch: " + e.message);
      return null;
    }
  }

  //sign out
  Future signOut() async{
    try{
      _auth.signOut();
      Future.delayed(Duration.zero);
      return true;
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future reauthenticateUser(String password)async{
    final user = _auth.currentUser();
    if(user != null){
      FirebaseUser firebaseUser = await user;
      AuthCredential credential = EmailAuthProvider.getCredential(
          email:firebaseUser.email,
          password:password
      );

      AuthResult result = await firebaseUser.reauthenticateWithCredential(credential).catchError((error){print(error); return null;});
      if(result != null){
        return result;
      }
      return null;
    }else{
      return null;
    }
  }

  Future changePassword(String password) async{
    try{
      FirebaseUser user = await _auth.currentUser();
      user.updatePassword(password);
      return true;
    }catch(e){
      print(e);
      return false;
    }
  }

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

  //check if current user is facebook user
  Future<bool> isFacebookUser()async{
    FirebaseUser user = await _auth.currentUser();
    for (UserInfo uinfo in user.providerData) {
      if(uinfo.providerId.toString().contains("facebook.com"))
        return true;
    }
    return false;
  }

  getProvider()async{
    return await isFacebookUser();
  }

}