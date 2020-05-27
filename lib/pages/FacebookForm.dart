import 'package:dog_prototype/pages/placeHolderHome.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gender_selector/gender_selector.dart';
import 'package:intl/intl.dart';

import '../firebasemain.dart';
import 'RegisterPage.dart';

class FacebookForm extends StatefulWidget {
  @override
  _FacebookFormState createState() => _FacebookFormState();
}

class _FacebookFormState extends State<FacebookForm> {

  final usernameController = TextEditingController();
  String dateOfBirth;
  String gender_type;
  DateTime _dateTime = DateTime.now();
  final f = new DateFormat('yyyy-MM-dd');
  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Add information to finish registration'),
          backgroundColor: Colors.grey[850],
          centerTitle: true
      ),
      body: _formSection(),
    );
  }

  Widget _formSection(){
    return ListView(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                key: Key('username'),
                controller: usernameController,
                decoration: new InputDecoration(
                    labelText: 'Username*',
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide()
                    )
                ),
                keyboardType: TextInputType.text,
                //validator: RegisterValidator.usernameValidator,
              ),

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
                            onDateTimeChanged: (DateTime newDateTime) {
                              if (mounted) {
                                setState(() => _dateTime = newDateTime

                                );
                                print("You Selected Date: ${newDateTime}");
                                dateOfBirth = '${f.format(_dateTime)}';


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

              GenderSelector(
                  onChanged: (gender) {
                    if(gender == Gender.FEMALE) {
                      gender_type = "FEMALE";
                    } else {
                      gender_type = "MALE";
                    }
                  }
              ),

              Padding(padding: EdgeInsets.only(top: 25.0)),

              MaterialButton(
                  minWidth: 375,
                  height: 50,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.grey[850])),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      register(usernameController.text,dateOfBirth,gender_type);
                    }
                  },
                  color: Colors.white,
                  textColor: Colors.black,
                  child: Text('Continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: Colors.black.withOpacity(0.6)))
              ),

              Padding(padding: EdgeInsets.only(top: 25.0)),

              MaterialButton(
                  minWidth: 375,
                  height: 50,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.grey[850])),
                  onPressed: () {
                    AuthService().signOut();
                  },
                  color: Colors.white,
                  textColor: Colors.black,
                  child: Text('Log out',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: Colors.black.withOpacity(0.6)))
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBottomPicker(Widget picker) {
    double _kPickerSheetHeight = 216.0;
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

  register(String username, String dateOfBirth, String gender) async{
    String email = await AuthService().getCurrentFirebaseUser().then((value) => value.email);
    dynamic result = await AuthService().addInformationToDatabase(email, username, dateOfBirth, gender);

    if(result != null){
      print('here');
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => Wrapper()
      ));
    }else{
      //TODO: ERROR MESSAGE
    }
  }
}