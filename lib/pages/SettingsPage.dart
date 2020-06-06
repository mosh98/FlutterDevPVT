import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dog_prototype/dialogs/ChangePasswordDialog.dart';
import 'package:dog_prototype/dialogs/DeleteAccountDialog.dart';
import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/services/HttpProvider.dart';
import 'package:dog_prototype/services/Validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {

  final User user;
  final bool isTest;
  SettingsPage({this.user, this.isTest});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final AuthService _auth = AuthService();
  String gender = "";
  String dateOfBirth = "";
  String profileImage;
  //bool _loadingImage = true;
  bool _loadingProfile = false;
  String snackText = "";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseUser firebaseUser;
  HttpProvider client;

  @override
  void initState() {
    setState(() {
      _loadingProfile = true;
    });
    if(widget.isTest == null || widget.isTest == false){
      _getFirebaseUser();
    }else{
      setState(() {
        _loadingProfile = false;
      });
    }
    //_getProfileImage();

    if(widget.user == null){
      gender = "Something went wrong with getting gender";
      dateOfBirth = "Something went wrong with getting date of birth";
    }else{
      if (widget.user.gender == "UNKNOWN") {
        gender = "-";
      }
      else {
        gender = widget.user.gender;
      }

      dateOfBirth = widget.user.dateOfBirth;
    }
    super.initState();
  }

//  _getProfileImage() async {
//    String token = await AuthService().getCurrentFirebaseUser().then((value) =>
//        value.getIdToken().then((value) => value.token));
//    try {
//      final url = await http.get(
//          'https://dogsonfire.herokuapp.com/images/${widget.user.userId}',
//          headers: {'Authorization': 'Bearer $token'});
//      if (url.statusCode == 200) {
//        setState(() {
//          profileImage = url.body;
//          _loadingImage = false;
//          _loadingProfile = false;
//        });
//      }else{
//        setState(() {
//          _loadingImage = false;
//          _loadingProfile = false;
//        });
//      }
//    } catch (e) {
//      print(e);
//
//    }
//  }

  _getFirebaseUser() async{
    firebaseUser = await AuthService().getCurrentFirebaseUser();
    if(firebaseUser == null){
      setState(() {
        _loadingProfile = false;
        return;
      });
      return;
    }
    String token = await AuthService().getToken();
    client = HttpProvider.instance(userToken: token);
    setState(() {
      _loadingProfile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.grey[850],
          title: Text('Settings'),
          centerTitle: true,
        ),
        body: Center(
          child: Text('Something went wrong with loading settings.'),
        ),
      );
    }

    return _loadingProfile == true ?
    Scaffold(
      key: _scaffoldKey,
      body: DefaultLoader(),
    )
        :
    Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Colors.grey[850],
          title: Text('Settings'),
          centerTitle: true,
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //_pictureInformationBuilder(),
                Text('PERSONAL INFORMATION',
                    style: TextStyle(fontSize: 15.0, color: Colors.grey)),
                _profileInformationBuilder(),
                Text('ACCOUNT',
                    style: TextStyle(fontSize: 15.0, color: Colors.grey)),
                _accountInformationBuilder(),
              ],
            ),
          ),
        )
    );
  }

//  Widget _pictureInformationBuilder() {
//    return Expanded(
//      flex: 3,
//      child: Center(
//        child: GestureDetector(
//            onTap: getImage,
//            child: Container(
//                height: 100,
//                width: 100,
//                child:
//                ClipRRect(
//                    borderRadius: BorderRadius.circular(10000.0),
//                    child: _loadingImage == true ?
//                    DefaultLoader()
//                        :
//                    CachedNetworkImage(
//                        imageUrl: profileImage,
//                        placeholder: (context, url) => DefaultLoader(),
//                        errorWidget: (context, url, error) => CircleAvatar(
//                            radius: 60,
//                            child: Icon(Icons.add_a_photo, color: Colors.white),
//                            backgroundColor: Colors.grey))
//                )
//            )
//        ),
//      ),
//    );
//  }

//  Future getImage() async {
//    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
//
//    setState(() {
//      _loadingImage = true;
//    });
//
//    bool uploadSuccessful = await _uploadImage(tempImage);
//    if (uploadSuccessful) {
//      _getProfileImage();
//    } else {
//      snackText = "Something went wrong with uploading picture.";
//
//      Scaffold.of(context).showSnackBar(SnackBar(content: Text(snackText)));
//
//      setState(() {
//        _loadingImage = false;
//      });
//    }
//  }
//
//  Future<bool> _uploadImage(File image) async {
//    try {
//      String token = await AuthService().getCurrentFirebaseUser().then((
//          value) => value.getIdToken().then((value) => value.token));
//
//      final response = await http.put(
//          'https://dogsonfire.herokuapp.com/images/${widget.user.userId}',
//          headers: {'Authorization': 'Bearer $token'});
//
//      if (response != null) {
//        print('First put of picture-upload went through :' +
//            response.statusCode.toString());
//        print('Response body :' + response.body);
//        try {
//          final nextResponse = await http.put(response.body,
//              body: image.readAsBytesSync());
//          if (nextResponse.statusCode == 200) {
//            print('Second put of picture-upload went through :' +
//                response.statusCode.toString());
//
//            return true;
//          } else {
//            print('Something went wrong with uploading picture, second put: ' +
//                response.statusCode.toString());
//            //TODO: POPUP USER
//            return false;
//          }
//        } catch (e) {
//          print(e);
//          return false;
//        }
//      } else {
//        print('Something went wrong with first put of profilepicture: ' +
//            response.statusCode.toString());
//        print(response.body);
//        return false;
//      }
//    } catch (e) {
//      print(e);
//      return false;
//    }
//  }

  Widget _profileInformationBuilder() {
    return Expanded(
        flex: 5,
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                key: Key('username'),
                  title: Text('Username'),
                  trailing: Text(widget.user.username ?? 'No username.'),
                  leading: Icon(Icons.lock)
              ),
              ListTile(
                key:Key('email'),
                title: Text('Email'),
                trailing: Text(
                  firebaseUser == null ?
                  'No email'
                  :
                  firebaseUser.email ?? 'No email'
                ),
                leading: Icon(Icons.lock),
              ),
              GestureDetector(
                key: Key('dateofbirth'),
                child: ListTile(
                  title: Text('Date of birth'),
                  trailing: Text(dateOfBirth ?? 'No date of birth'),
                ),
                onTap: () {
                  _setDateOfBirth();
                },
              ),
              ListTile(
                key: Key('gender'),
                title: Text('Gender'),
                trailing: DropdownButton<String>(
                  value: gender,

                  onChanged: (String newValue) {
                    setState(() {
                      _setGender(newValue);
                      gender = newValue;
                    });
                  },
                  items: <String>[
                    'MALE', 'FEMALE', '-'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 15.0),),
                    );
                  }).toList(),
                ),
              )
            ],
          ).toList(),
        )
    );
  }

  Widget _accountInformationBuilder() {
    return Expanded(
        flex: 7,
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                key: Key('changepassword'),
                title: Text('Change Password'),
                onTap: () async {
                  await showDialog(context: context,
                      barrierDismissible: false,
                      child: ChangePasswordDialog(
                        context: context, scaffoldKey: _scaffoldKey,));
                },
              ),
              ListTile(
                key: Key('deleteaccount'),
                  title: Text('Delete account'),
                  trailing: Icon(Icons.error),
                  onTap: () async {
                    await showDialog(context: context,
                        barrierDismissible: false,
                        child: DeleteAccountDialog(
                          context: context, scaffoldKey: _scaffoldKey, provider: widget.isTest ? null : await widget.user.getProvider(),
                        )
                    );
                  }
              ),
              ListTile(
                key:Key('logout'),
                title: Text('Log out'),
                onTap: () {
                  _logout();
                },
              ),
            ],
          ).toList(),
        )
    );
  }

  void _logout() async {
    await showDialog(context: context,
        barrierDismissible: false,
        child: AlertDialog(
          contentPadding: EdgeInsets.all(10.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            MaterialButton(
              key: Key('logoutno'),
              child: Text('No'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
            ),
            MaterialButton(
              key: Key('logoutyes'),
              child: Text('Yes'),
              onPressed: () async {
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

  _setDateOfBirth() async {
    await dateOfBirthWidgetHelper();

    try {
      processDataFeedback();

      dynamic result = await client.updateUserDateOfBirth(dateOfBirth);
      if (result == true) {
        snackText = "Succesfully updated date of birth.";
        setState(() {
          widget.user.setDateOfBirth(dateOfBirth);
        });
      }else{
        snackText = "Something went wrong with updating your date of birth, please try again.";
      }
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText)));
    } catch (e) {
      print(e);
      print('catch on trying to call HttpProvider.dateOfBirth');
    }
  }

  dateOfBirthWidgetHelper() async{
    DateTime _dateTime = DateTime.now();
    final f = new DateFormat('yyyy-MM-dd');
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return _buildBottomPicker(
          CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: DateTime.now(),
            minimumDate: DateTime(1900),
            maximumDate: DateTime.now(),
            onDateTimeChanged: (DateTime newDateTime) {
              if (mounted) {
                _dateTime = newDateTime;

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

  _setGender(String gender) async {

    processDataFeedback();

    if (gender == "-") {
      gender = "UNKNOWN";
    }

    try {
      dynamic result = await client.updateUserGender(gender);
      if(result == true){
        snackText = "Succesfully updated gender.";
        setState(() {
          widget.user.setGender(gender);
        });
      }else{
        snackText = "Something went wrong with updating your gender, please try again.";
      }
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText)));
    } catch (e) {
      print(e);
      print('catch on trying to call HttpProvider.gender');
    }
  }

  processDataFeedback(){
    snackText = "Processing..";
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText), duration: Duration(seconds:1)));
  }
}