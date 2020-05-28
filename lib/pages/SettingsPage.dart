import 'dart:convert';
import 'dart:io';

import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {

  final User user;
  SettingsPage({this.user});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final AuthService _auth = AuthService();
  String gender = "";
  String dateOfBirth = "";
  User user;
  File _image;

  @override
  void initState() {
    if(user == null){
      user = widget.user;
    }
    gender = user.gender;
    dateOfBirth = user.dateOfBirth;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Colors.grey[850],
          title: Text('Settings'),
          centerTitle: true,
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _pictureInformationBuilder(),
              Text('PROFILE', style: TextStyle(fontSize: 15.0, color: Colors.grey)),
              _profileInformationBuilder(),
              Text('ACCOUNT', style: TextStyle(fontSize: 15.0, color: Colors.grey)),
              _accountInformationBuilder(),
            ],
          ),
        )
    );
  }

  Widget _pictureInformationBuilder(){
    return Expanded(
      flex:3,
      child: Center(
        child: GestureDetector(
            onTap: getImage,
            child: _image == null
                ? CircleAvatar(radius: 60, child: Icon(Icons.add_a_photo, color: Colors.white), backgroundColor:Colors.grey)
                : CircleAvatar(radius: 60, backgroundImage: FileImage(_image))
        ),
      ),
    );
  }

  Future getImage() async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  Widget _profileInformationBuilder(){
    return Expanded(
        flex:5,
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                title: Text('Username'),
                trailing: Text(user.username ?? 'No username.'),
                leading: Icon(Icons.lock)
              ),
              ListTile(
                  title: Text('Email'),
                  trailing: Text(user.email ?? 'No email'),
                  leading: Icon(Icons.lock),
              ),
              GestureDetector(
                child: ListTile(
                  title: Text('Date of birth'),
                  trailing: Text(dateOfBirth ?? 'No date of birth'),
                ),
                onTap: (){_setDateOfBirth();},
              ),
              ListTile(
                title: Text('Gender'),
                trailing: DropdownButton<String>(
                  value: gender,

                  onChanged: (String newValue) {setState(() {
                    gender = newValue;
                  });_setGender(newValue);},
                  items: <String>[
                    'MALE', 'FEMALE'
                  ].map<DropdownMenuItem<String>>((String value){
                    return DropdownMenuItem<String>(
                      value:value,
                      child:Text(value, style: TextStyle(fontSize: 15.0),),
                    );
                  }).toList(),
                ),
              )
            ],
          ).toList(),
        )
    );
  }

  Widget _accountInformationBuilder(){
    return Expanded(
        flex:2,
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              GestureDetector(
                child: ListTile(
                  title: Text('Change Password'),
                ),
                onTap: (){_changePassword();},
              ),
              ListTile(
                title: Text('Log out'),
                onTap: (){_logout();},
              ),
            ],
          ).toList(),
        )
    );
  }

  void _logout() async{
    await showDialog(context: context,
        barrierDismissible: false,
        child: AlertDialog(
          title: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            MaterialButton(
              child: Text('No'),
              onPressed: (){Navigator.of(context, rootNavigator: true).pop('dialog');},
            ),
            MaterialButton(
              child: Text('Yes'),
              onPressed: () async{
               Navigator.of(context, rootNavigator: true).pop('dialog');
               await _auth.signOut();
               Navigator.pop(context);
              },
            )
          ],
        )
    );
  }

  double _kPickerSheetHeight = 216.0;
  _setDateOfBirth() async{ //TODO: FACTOR
    DateTime _dateTime = DateTime.now();
    final f = new DateFormat('yyyy-MM-dd');
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return _buildBottomPicker(
          CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: DateTime.now(),
            maximumDate: DateTime.now(),
            onDateTimeChanged: (DateTime newDateTime) {
              if (mounted) {
                _dateTime = newDateTime;
                print("You Selected Date: ${newDateTime}");
                dateOfBirth = '${f.format(_dateTime)}';
              }
            },
          ),
        );
      },
    );

    setState(() {
      dateOfBirth = '${f.format(_dateTime)}';
    });
    print(dateOfBirth);

    try{
      print(dateOfBirth);
      final http.Response response = await http.put( //register to database
          'https://dogsonfire.herokuapp.com/users',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token))}'
          },
          body: jsonEncode(<String,String>{
            "dateOfBirth": dateOfBirth,
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print(response.statusCode);
        User newUser = await AuthService().createUserModel(AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken()));
        setState(() {
          user = newUser;
        });
      }else{ //Something went wrong
        print(response.statusCode);
        print(response.body);
      }
    }catch(e){
      print(e);
    }
  }

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

  _setGender(String gender) async{
    try{
      final http.Response response = await http.put( //register to database
          'https://dogsonfire.herokuapp.com/users',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token))}'
          },
          body: jsonEncode(<String,String>{
            "gender": gender,
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print(response.statusCode);
        User newUser = await AuthService().createUserModel(AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken()));
        setState(() {
          user = newUser;
        });
      }else{ //Something went wrong
        print(response.statusCode);
        print(response.body);
      }
    }catch(e){
      print(e);
    }
  }

  //TODO: NOT FINISHED
  _changePassword()async{
    String password = "";

    await showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200.0, maxWidth: 450.0),
                  child: Dialog(
                    child: ListView(
                      padding: EdgeInsets.all(10.0),
                      children: [
                        TextFormField(
                          decoration: new InputDecoration(
                            hintText: "New password* ",
                          ),
                          obscureText: true,
                          onChanged: (String value){
                            password = value;
                          },
                        ),
                        Row(
                          children: [
                            RaisedButton(
                              child: Text('Back'),
                              onPressed: (){Navigator.of(context, rootNavigator: true).pop('dialog'); return;},
                            ),
                            Padding(padding:EdgeInsets.only(left:20)),
                            RaisedButton(
                              child: Text('Renew password'),
                              onPressed: () async{
                                Navigator.of(context, rootNavigator: true).pop('dialog');
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
        },
    );

    if(password.trim().isNotEmpty && password.length > 5){
      print('here');
      bool changedPassword = await AuthService().changePassword(password);
      if(changedPassword){
        print('worked'); //TODO: NOTIFY USER
        await _auth.signOut();
      }else{
        print('did not work'); //TODO: NOTIFY USER
      }
    }else{
      print('cant be empty or less than 6 symbols'); //TODO: NOTIFY USER
    }
  }
}