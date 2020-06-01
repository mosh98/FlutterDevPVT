import 'package:dog_prototype/pages/placeHolderHome.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/services/Validator.dart';
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
  String gender_type = 'MALE'; //DEFAULT
  DateTime _dateTime = DateTime.now();
  String dateOfBirth;
  final f = new DateFormat('yyyy-MM-dd');
  final _formKey = GlobalKey<FormState>();
  String snackText = "";

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
      padding: EdgeInsets.all(15),
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                validator: Validator.usernameValidator,
              ),

              Padding(padding: EdgeInsets.only(top:15),),

              Container(
                  decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(5.0),
                      border: Border.all(color: Colors.black.withOpacity(0.4))
                  ),
                child: ListTile(
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        'Gender',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: Colors.black.withOpacity(0.4))),
                  ),
                  trailing: DropdownButton<String>(
                    value: gender_type,

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

              Padding(padding: EdgeInsets.only(top:15),),

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
                      child: Text('Date of Birth ${f.format(_dateTime)}',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: Colors.black.withOpacity(0.4)))
                  )
              ),

              Padding(padding: EdgeInsets.only(top: 80.0)),

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

              Padding(padding: EdgeInsets.only(top: 15.0)),

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

    if(gender == '-'){
      gender = "UNKNOWN";
    }

    if(dateOfBirth == null){
      dateOfBirth = f.format(_dateTime);
    }

    dynamic result = await AuthService().addInformationToDatabase(username, dateOfBirth, gender);

    if(result != null){
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => Wrapper()
      ));
    }else{
      snackText = 'Something went wrong with adding your information.';
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText),));
    }
  }
}