import 'dart:convert';

import 'package:dog_prototype/pages/mapPage.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:gender_selector/gender_selector.dart';

class Signup extends StatelessWidget {
  @override

  //TODO:
  /**
   * - Create default value for date of birth variable, returns null if not clicked on it now.
   */
  
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

  final _formKey = GlobalKey<FormState>();
  DateTime _dateTime = DateTime.now();
  final f = new DateFormat('yyyy-MM-dd');
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  String date_of_birth;
  String gender_type;

  @override
  Widget build(BuildContext context) {
 
    return ListView(
      children: <Widget>[
        Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Padding(
                  padding: const EdgeInsets.only(left:20, right: 20, top: 20),
                  child:
                  MaterialButton(
                      minWidth: 375,
                      height: 50,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.grey[850])),
                      onPressed: () {},
                      color: Colors.grey[850],
                      textColor: Colors.white,
                      child: Text('Sign up with FaceBook',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, fontFamily: 'RobotoMono'))
                  )
              ),

              Padding(
                  padding: const EdgeInsets.only(left: 160.0, top: 20.0),
                  child:
                  Text(
                      'or with email',
                      style: TextStyle(fontFamily: 'RobotoMono', color: Colors.black.withOpacity(0.3)),
                      textAlign: TextAlign.center
                  )
              ),
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
                  validator: (email) {
                    if (EmailValidator.validate(email) != true) {
                      return 'Please enter a valid mailadress';
                    }
                    return null;
                    
                  },
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
                  validator: (value) {
                    if (value.isEmpty || value.length < 6 || value.length > 16) {
                      return 'Please enter a valid password which is at least 6 characters long';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value.isEmpty || value.length > 16) {
                      return 'Please enter a valid username';
                    }
                    return null;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left:20, right: 20, top: 10),
                child:
                MaterialButton(
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
                        initialDateTime: DateTime(1990),
                        maximumDate: DateTime.now(),
                        minimumDate: DateTime(1900),
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
                )),
                
              ),

              Padding(
                padding: const EdgeInsets.only(left:20, right: 20, top: 10),
                child:
                GenderSelector(
                onChanged: (gender) {
                if(gender == Gender.FEMALE) {
                gender_type = "FEMALE";
                } else {
                gender_type = "MALE";
                }
                print(gender_type);
                }
              )
              ),

              Padding(
                  padding: const EdgeInsets.only(left: 75, right: 20, top: 10),
                  child:
                  Text(
                    'By proceeding you also agree \n to the Terms of Service and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'RobotoMono', color: Colors.black.withOpacity(0.3)),
                  )
              ),

              Padding(
                  padding: const EdgeInsets.only(left:20, right: 20, top: 20),
                  child:
                  MaterialButton(
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
                          Scaffold.of(context)
                              .showSnackBar(SnackBar(content: Text('Processing Data')));
                              signin(usernameController.text, emailController.text, passwordController.text, date_of_birth, gender_type);
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
      ],
    );
  }

    Future<void> signin(String username, String email, String password, String date_of_birth, String gender_type) async {
    final formState = _formKey.currentState;
 
    if (formState.validate()) {
      formState.save();
      try {
        final http.Response response = await http.post(
            'https://redesigned-backend.herokuapp.com/user/register',
            headers:<String, String>{
              'Content-Type' : 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String,String>{
              "username": username, 
              "email": email, 
              "password": password, 
              "date_of_birth": date_of_birth, 
              "gender_type": gender_type
            })
        );

        if(response.statusCode==200){
            Navigator.of(context).push(
                      MaterialPageRoute<Null>(
                          builder: (BuildContext context) {
                            return new MapPage();
                          }));

        }else{
            print(response.statusCode);
        }
      } catch (e) {
        print(e.message);
      }
      
    }
  }
}