import 'dart:convert';

import 'package:dog_prototype/loaders/CustomLoader.dart';
import 'package:dog_prototype/pages/mapPage.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/services/Validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:gender_selector/gender_selector.dart';

import 'ProfilePage.dart';
import 'placeHolderHome.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Sign up';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
            title: Text(appTitle),
            backgroundColor: Colors.grey[850],
            centerTitle: true
        ),
        body: MyCustomForm(),
      ),
    );
  }
}

double _kPickerSheetHeight = 216.0;
Widget _buildBottomPicker(Widget picker) {
  return Container(
    height: _kPickerSheetHeight,
    padding: const EdgeInsets.only(top: 6.0),
    color: CupertinoColors.white,
    child: DefaultTextStyle(
      style: const TextStyle(
        color: CupertinoColors.black,
        fontSize: 22.0,
      ),
      child: GestureDetector(
        // Blocks taps from propagating to the modal sheet and popping.
        onTap: () {},
        child: SafeArea(
          top: false,
          child: picker,
        ),
      ),
    ),
  );
}


class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  DateTime _dateTime = DateTime.now();
  final f = new DateFormat('yyyy-MM-dd');
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  String date_of_birth;
  String gender_type = 'MALE'; //DEFAULT
  bool _isLoading = false;
  CustomLoader customLoader = CustomLoader();

  @override
  Widget build(BuildContext context) {
    return _isLoading == true ?
      customLoader
      :
      Container(
     child: ListView(
            children:[ Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left:20, right: 20, top: 20),
                      child:
                      TextFormField(
                        key: Key('email'),
                        controller: emailController,
                        decoration: new InputDecoration(
                            labelText: 'Email*',
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide()
                            )
                        ),
                        keyboardType: TextInputType.text,
                        validator: Validator.emailValidator,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left:20, right: 20, top: 10),
                      child:
                      TextFormField(
                        key: Key('password'),
                        controller: passwordController,
                        decoration: new InputDecoration(
                            labelText: 'Choose password*',
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide()
                            )
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        validator: Validator.passwordValidator,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left:20, right: 20, top: 10),
                      child:
                      TextFormField(
                        key: Key('repeatPassword'),
                        decoration: new InputDecoration(
                            labelText: 'Repeat password*',
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide()
                            )
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        validator: (String pass2){return Validator.matchPasswords(passwordController.text, pass2);}
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left:20, right: 20, top: 10),
                      child:
                      TextFormField(
                        key: Key('username'),
                        controller: usernameController,
                        decoration: new InputDecoration(
                            labelText: 'Choose username*',
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide()
                            )
                        ),
                        keyboardType: TextInputType.text,
                        validator: Validator.usernameValidator,
                      ),
                    ),

                    Padding(
                      key: Key('gender'),
                      padding: const EdgeInsets.only(left:20, right: 20, top: 10),
                      child:  Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: new BorderRadius.circular(5.0),
                            border: Border.all(color: Colors.black.withOpacity(0.4))
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left:10),
                          child: DropdownButton<String>(
                            value: gender_type,
                            isExpanded: true,
                            onChanged: (String newValue) {
                              setState(() {
                                gender_type = newValue;
                              });
                            },
                            items: <String>[
                              'MALE', 'FEMALE', '-'
                            ].map<DropdownMenuItem<String>>((String value){
                              return DropdownMenuItem<String>(
                                value:value,
                                child:Text(value, style: TextStyle(fontSize: 15.0),),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left:20, right: 20, top: 10),
                      child:
                      MaterialButton(
                        key: Key('dateOfBirth'),
                          minWidth: 375,
                          height: 50,
                          shape: new RoundedRectangleBorder(

                              borderRadius: new BorderRadius.circular(5.0),
                              side: BorderSide(color: Colors.black.withOpacity(0.4)))
                          ,
                          onPressed: () {
                            showCupertinoModalPopup<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return _buildBottomPicker(
                                  CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.date,
                                    maximumDate: DateTime.now(),
                                    minimumDate: DateTime(1900),
                                    initialDateTime: DateTime(1990),
                                    onDateTimeChanged: (DateTime newDateTime) {
                                      if (mounted) {
                                        setState(() => _dateTime = newDateTime

                                        );
                                        print("You Selected Date: ${newDateTime}");
                                        date_of_birth = '${f.format(_dateTime)}';


                                      }
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          child:
                          Align(
                              alignment: Alignment.centerLeft,
                              key:Key('date_of_birth'),
                              child:

                              Text('Date of Birth ${f.format(_dateTime)}',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: Colors.black.withOpacity(0.4)))
                          )
                      ),

                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:20, right: 20, top: 40),
                      child: Center(
                        child: Text(
                          'By proceeding you also agree \n to the Terms of Service and Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'RobotoMono', color: Colors.black.withOpacity(0.3)),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left:20, right: 20, top: 20),
                        child:
                        MaterialButton(
                          key: Key('signUp'),
                            minWidth: 375,
                            height: 50,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0),
                                side: BorderSide(color: Colors.grey[850])),
                            onPressed: () {
                              // Validate returns true if the form is valid, or false
                              // otherwise.
                              if (_formKey.currentState.validate()) {
                                // If the form is valid, display a Snackbar.
                                setState(() {
                                  customLoader = CustomLoader(textWidget: Text('Processing data..'),padding: Padding(padding:EdgeInsets.only(top:15)));
                                  _isLoading = true;
                                });
                                register(usernameController.text, emailController.text, passwordController.text, date_of_birth, gender_type);
                              }
                            },
                            color: Colors.white,
                            textColor: Colors.black,
                            child: Text('Sign up',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: Colors.black.withOpacity(0.6)))
                        )
                    ),
                  ],
                ),
              ),
            ]
          ),

    );
  }

  Future<void>register(String username, String email, String password, String dateOfBirth, String gender)async{
    try {
      if(gender == "-") {
        gender = "UNKNOWN"; 
      }

      if(dateOfBirth == null){
        dateOfBirth = f.format(_dateTime);
      }

      dynamic result = await _auth.registerWithEmailAndPassword(username, email, dateOfBirth, gender, password);

      dynamic zz = await createAndSaveToken(username, email);

      setState(() {
        _isLoading = false;
      });

      if(result != null || result != '200'){
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(result.toString())));
      }
    } catch (e) {
      print(e.message + "catch");
    }
  }

  void _signInWithFacebook() {
    AuthService().signInWithFacebook(context);
  }



  Future<http.Response> createAndSaveToken(String username, String email) async {

    String token;
    FirebaseMessaging Fcm = new FirebaseMessaging();

    await Fcm.getToken().then((value) => token = value);

      return http.post(
        'https://fcm-token.herokuapp.com/user/saveFcm',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email':email,
          'fcmToken': token
        }),
      );
  }

  Future<http.Response> createAndSaveToken1(String username, String email) async {

    FirebaseMessaging Fcm = new FirebaseMessaging();

    String token = await Fcm.getToken();

    try{
      final response = await http.post(
        'https://fcm-token.herokuapp.com/user/saveFcm',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email':email,
          'fcmToken': token
        }),
      );

      if(response != null){
        if(response.statusCode==200){
          print('Creating and saving token succesful');
          print(response.statusCode);
          print(response.body);
        }else{
          print('Creating and saving token was unsuccesful');
          print(response.statusCode);
          print(response.body);
        }
      }else{
        print('Response is null.');
      }
    }catch(e){
      print(e);
      return null;
    }
  }


}
