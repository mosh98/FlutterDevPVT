import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class HttpProvider{

  static final String _SERVER = "https://dogsonfire.herokuapp.com";

  final String userToken;

  HttpProvider.instance({@required this.userToken});

  Future<bool> updateUserGender(String gender) async{
    try {
      final http.Response response = await http.put(
          '$_SERVER/users',
          headers: <String, String>{
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $userToken'
          },
          body: jsonEncode(<String, String>{
            "gender": gender,
          })
      );

      if (response.statusCode == 200) {
        print('Updating gender went through. Response code: ${response.statusCode}');
        return true;
      } else { //Something went wrong
        print('Could not update gender. Response code: ${response.statusCode}');
        print('body: ${response.body}');
        return false;
      }
    } catch (e) {
      print(e);
      print('catch on trying to update gender');
      return false;
    }
  }

  Future<bool> updateUserDateOfBirth(String dateOfBirth) async{
    try {
      final http.Response response = await http.put(
          '$_SERVER/users',
          headers: <String, String>{
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $userToken'
          },
          body: jsonEncode(<String, String>{
            "dateOfBirth": dateOfBirth,
          })
      );

      if (response.statusCode == 200) {
        print('Updating date of birth went through. Response code: ${response.statusCode}');
        return true;
      } else { //Something went wrong
        print('Could not update date of birth. Response code: ${response.statusCode}');
        print('body: ${response.body}');
        return false;
      }
    } catch (e) {
      print(e);
      print('catch on trying to update date of birth');
      return false;
    }
  }
}