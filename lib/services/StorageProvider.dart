import 'dart:io';

import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class StorageProvider{

  final User user;
  StorageProvider({@required this.user});

  _getProfileImage() async{
    String token = await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token));
    try{
      final url = await http.get('https://dogsonfire.herokuapp.com/images/${user.userId}', headers:{'Authorization': 'Bearer $token'});
      if(url.statusCode==200){
        return url.body;
      }
      return null;
    }catch(e){
      print(e);
      return null;
    }
  }

  Future<bool> _uploadImage(File image) async{
    try{
      String token = await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token));

      final response = await http.put('https://dogsonfire.herokuapp.com/images/${user.userId}', headers:{'Authorization': 'Bearer $token'});

      if(response != null){
        print('1/2 of picture-upload went through :' + response.statusCode.toString());
        print('Response body :' + response.body);
        try{
          final nextResponse = await http.put(response.body,
              body: image.readAsBytesSync());
          if(nextResponse.statusCode == 200){
            print('2/2 of picture-upload went through :' + response.statusCode.toString() + ". SUCCESS.");

            return true;
          }else{
            print('Something went wrong with uploading picture, 2/2: ' + response.statusCode.toString());
            return false;
          }
        }catch(e){
          print(e);
          return false;
        }
      }else{
        print('Something went wrong with uploading picture, 1/2 ' + response.statusCode.toString());
        print(response.body);
        return false;
      }
    }catch(e){
      print(e);
      return false;
    }
  }
}