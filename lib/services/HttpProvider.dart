import 'dart:convert';
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class HttpProvider{

  static const String _SERVER = "https://dogsonfire.herokuapp.com";

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

  Future<bool> deleteDog(Dog dog) async{
    try{
      String token = await refreshToken();
      final response = await http.delete('$_SERVER/dogs/${dog.uuid}', headers:{'Authorization': 'Bearer $token'});
      if(response.statusCode == 204){
        print('Deleting dog was succesful. Response code: ${response.statusCode}');
        return true;
      }else{
        print('Something went wrong with deleting dog. Response code: ${response.statusCode}');
        print(response.body);
        return false;
      }
    }catch(e){
      print('Something went wrong with deleting dog. Exception: $e');
      return false;
    }
  }

  Future<Dog> addDog(String dogName, String breed, String dateOfBirth, String gender, bool neut) async{
    try{
      String token = await refreshToken();

      final http.Response response = await http.post(
          '$_SERVER/dogs',
          headers:{
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String,String>{
            'name':dogName,
            'breed':breed,
            'dateOfBirth':dateOfBirth,
            'gender':gender,
            'neutered':neut.toString(),
            'description':null,
          })
      );

      if(response.statusCode==201){
        print('Adding dog was succesful. Response code: ${response.statusCode}');
        print(response.body);
        Dog dog = Dog.fromJson(json.decode(response.body));
        return dog;
      }else{
        print('Something went wrong with adding dog. Response code: ${response.statusCode}');
        print(response.body);
        return null;
      }
    }catch(e){
      print('Something went wrong with adding dog. Exception: $e');
      return null;
    }
  }

  Future<bool> updateDescriptionUser(String desc) async{
    try{
      String token = await refreshToken();
      final http.Response response = await http.put( //register to database
          '$_SERVER/users',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String,String>{
            "description":desc,
          })
      );

      if(response.statusCode==200){
        print('Updating desc was succesful. Response code: ${response.statusCode}');
        return true;
      }else{
        print('Something went wrong with updating desc. Response code: ${response.statusCode}');
        print(response.body);
        return false;
      }
    }catch(e){
      print('Something went wrong with updating desc. Exception: $e');
      return false;
    }
  }

  Future<String> getUsers(String input)async{
    try{
      String token = await refreshToken();
      final response = await http.get('$_SERVER/users?search=$input', headers: {
        'Authorization': 'Bearer $token',
      });

      if(response.statusCode == 200){
        print('Getting list of users was succesful. Response code: ${response.statusCode}');
        return response.body;
      }
      print('Could not get list of users. Response code: ${response.statusCode}');
      print(response.body);
      return null;
    }catch(e){
      print('Could not get list of users. Exception: $e');
      return null;
    }
  }

  Future<bool> addFriend(User friend)async{
    String token = await refreshToken();
    try {
      final response = await http.post(
          '$_SERVER/friends/${friend
              .userId}', headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        print('Succesfully added friend. Response code: ${response.statusCode}');
        return true;
      }
      print('Could not add friend. Response code: ${response.statusCode}');
      print(response.body);
      return false;
    } catch (e) {
      print('Could not add friend. Exception: $e');
      return false;
    }
  }

  Future<bool> removeFriend(User friend) async{
    String token = await refreshToken();
    try {
      final response = await http.delete(
          '$_SERVER/friends/${friend
              .userId}', headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        print('Succesfully deleted friend. Response code: ${response.statusCode}');
        return true;
      }
      print('Could not remove friend. Response code: ${response.statusCode}');
      print(response.body);
      return false;
    } catch (e) {
      print('Could not remove friend. Exception: $e');
      return false;
    }
  }

  Future<bool> setNameDog(Dog dog, String name)async{
    String token = await refreshToken();
    try{
      final http.Response response = await http.put(
          '$_SERVER/dogs',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String,String>{
            "name": name,
          })
      );

      if(response.statusCode==200){
        print("Updating dog name was succesful. Response code: " + response.statusCode.toString());
        return true;
      }
      print("Something went wrong with updating dog name. Response code: " + response.statusCode.toString());
      print(response.body);
      return false;
    }catch(e){
      print("Something went wrong with updating dog name. Exception: $e");
      return false;
    }
  }

  Future<bool> setBreed(Dog dog, String breed)async{
    String token = await refreshToken();
    try{
      final http.Response response = await http.put(
          '$_SERVER/dogs',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String,String>{
            "name": dog.name,
            "breed": breed,
          })
      );

      if(response.statusCode==200){
        print("Updating breed was succesful. Response code: " + response.statusCode.toString());
        return true;
      }else{ //Something went wrong
        print("Something went wrong with updating breed. Response code: " + response.statusCode.toString());
        print(response.body);
        return false;
      }
    }catch(e){
      print("Something went wrong with updating breed. Exception: $e");
      return false;
    }
  }

  Future<bool> setDateOfBirthDog(Dog dog, String dateOfBirth) async{
    String token = await refreshToken();
    try{
      final http.Response response = await http.put( //register to database
          '$_SERVER/dogs',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String,String>{
            "name":dog.name,
            "dateOfBirth": dateOfBirth,
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print("Updating date of birth was succesful. Response code: " + response.statusCode.toString());
        return true;
      }else{ //Something went wrong
        print("Something went wrong with updating date of birth. Response code: " + response.statusCode.toString());
        print(response.body);
        return false;
      }
    }catch(e){
      print("Something went wrong with updating date of birth. Exception: $e");
      return false;
    }
  }

  Future<bool> updateNeutered(Dog dog, bool neut)async{
    String token = await refreshToken();
    try{
      final http.Response response = await http.put( //register to database
          '$_SERVER/dogs',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String,String>{
            "name":dog.name,
            "neutered":neut.toString(),
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print("Updating neutured was succesful. Response code: " + response.statusCode.toString());
        return true;
      }else{ //Something went wrong
        print("Something went wrong with updating neutured. Response code: " + response.statusCode.toString());
        print(response.body);
        return false;
      }
    }catch(e){
      print("Something went wrong with updating neutured. Exception: $e");
      return false;
    }
  }

  Future<bool> setGenderDog(Dog dog, String gender)async{
    String token = await refreshToken();
    try{
      final http.Response response = await http.put( //register to database
          '$_SERVER/dogs',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String,String>{
            "name":dog.name,
            "gender":gender,
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print("Updating gender was succesful. Response code: " + response.statusCode.toString());
        return true;
      }else{ //Something went wrong
        print("Something went wrong with updating gender. Response code: " + response.statusCode.toString());
        print(response.body);
        return false;
      }
    }catch(e){
      print("Something went wrong with updating gender. Exception: $e");
      return false;
    }
  }

  Future<bool> setDescriptionDog(Dog dog, String desc)async{
    String token = await refreshToken();
    try{
      final http.Response response = await http.put( //register to database
          '$_SERVER/dogs',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String,String>{
            "name":dog.name,
            "description":desc,
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print("Updating description was succesful. Response code: " + response.statusCode.toString());
        return true;
      }else{ //Something went wrong
        print("Something went wrong with updating description. Response code: " + response.statusCode.toString());
        print(response.body);
        return false;
      }
    }catch(e){
      print("Something went wrong with updating description. Exception: $e");
      return false;
    }
  }

  Future<String> refreshToken()async{
    String token = await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token));
    return token;
  }
}