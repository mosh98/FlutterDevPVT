import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dog_prototype/dialogs/ChangePasswordDialog.dart';
import 'package:dog_prototype/dialogs/DeleteAccountDialog.dart';
import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/services/Validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String profileImage;
  bool _loadingImage = false;
  bool _loadingProfile = false;
  String snackText = "";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseUser firebaseUser;

  @override
  void initState() {
    setState(() {
      _loadingProfile= true;
    });
    _getFirebaseUser();
    _getProfileImage();

    if (widget.user.gender == "UNKNOWN") {
      gender = "-";
    }
    else {
      gender = widget.user.gender;
    }

    dateOfBirth = widget.user.dateOfBirth;
    super.initState();
  }

  _getProfileImage() async {
    String token = await AuthService().getCurrentFirebaseUser().then((value) =>
        value.getIdToken().then((value) => value.token));
    try {
      final url = await http.get(
          'https://dogsonfire.herokuapp.com/images/${widget.user.userId}',
          headers: {'Authorization': 'Bearer $token'});
      if (url.statusCode == 200) {
        setState(() {
          profileImage = url.body;
        });
      }
      setState(() {
        _loadingImage = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _loadingImage = false;
      });
    }
  }

  _getFirebaseUser() async{
    firebaseUser = await AuthService().getCurrentFirebaseUser();
    setState(() {
      _loadingProfile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null || firebaseUser == null) {
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

    return _loadingProfile == true || profileImage == null ?
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _pictureInformationBuilder(),
              Text('PERSONAL INFORMATION',
                  style: TextStyle(fontSize: 15.0, color: Colors.grey)),
              _profileInformationBuilder(),
              Text('ACCOUNT',
                  style: TextStyle(fontSize: 15.0, color: Colors.grey)),
              _accountInformationBuilder(),
            ],
          ),
        )
    );
  }

  Widget _pictureInformationBuilder() {
    return Expanded(
      flex: 3,
      child: Center(
        child: GestureDetector(
            onTap: getImage,
            child: Container(
                height: 100,
                width: 100,
                child:
                ClipRRect(
                    borderRadius: BorderRadius.circular(10000.0),
                    child: _loadingImage == true ?
                    DefaultLoader()
                        :
                    CachedNetworkImage(
                        imageUrl: profileImage,
                        placeholder: (context, url) => DefaultLoader(),
                        errorWidget: (context, url, error) => CircleAvatar(
                            radius: 60,
                            child: Icon(Icons.add_a_photo, color: Colors.white),
                            backgroundColor: Colors.grey))
                )
            )
        ),
      ),
    );
  }

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _loadingImage = true;
    });

    bool uploadSuccessful = await _uploadImage(tempImage);
    if (uploadSuccessful) {
      _getProfileImage();
    } else {
      snackText = "Something went wrong with uploading picture.";

      Scaffold.of(context).showSnackBar(SnackBar(content: Text(snackText)));

      setState(() {
        _loadingImage = false;
      });
    }
  }

  Future<bool> _uploadImage(File image) async {
    try {
      String token = await AuthService().getCurrentFirebaseUser().then((
          value) => value.getIdToken().then((value) => value.token));

      final response = await http.put(
          'https://dogsonfire.herokuapp.com/images/${widget.user.userId}',
          headers: {'Authorization': 'Bearer $token'});

      if (response != null) {
        print('First put of picture-upload went through :' +
            response.statusCode.toString());
        print('Response body :' + response.body);
        try {
          final nextResponse = await http.put(response.body,
              body: image.readAsBytesSync());
          if (nextResponse.statusCode == 200) {
            print('Second put of picture-upload went through :' +
                response.statusCode.toString());

            return true;
          } else {
            print('Something went wrong with uploading picture, second put: ' +
                response.statusCode.toString());
            //TODO: POPUP USER
            return false;
          }
        } catch (e) {
          print(e);
          return false;
        }
      } else {
        print('Something went wrong with first put of profilepicture: ' +
            response.statusCode.toString());
        print(response.body);
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Widget _profileInformationBuilder() {
    return Expanded(
        flex: 5,
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                  title: Text('Username'),
                  trailing: Text(widget.user.username ?? 'No username.'),
                  leading: Icon(Icons.lock)
              ),
              ListTile(
                title: Text('Email'),
                trailing: Text(firebaseUser.email ?? 'No email'),
                leading: Icon(Icons.lock),
              ),
              GestureDetector(
                child: ListTile(
                  title: Text('Date of birth'),
                  trailing: Text(dateOfBirth ?? 'No date of birth'),
                ),
                onTap: () {
                  _setDateOfBirth();
                },
              ),
              ListTile(
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
        flex: 4,
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                title: Text('Change Password'),
                onTap: () async {
                  await showDialog(context: context,
                      barrierDismissible: false,
                      child: ChangePasswordDialog(
                        context: context, scaffoldKey: _scaffoldKey,));
                },
              ),
              ListTile(
                  title: Text('Delete account'),
                  trailing: Icon(Icons.error),
                  onTap: () async {
                    await showDialog(context: context,
                        barrierDismissible: false,
                        child: DeleteAccountDialog(
                          context: context, scaffoldKey: _scaffoldKey, provider: await widget.user.getProvider(),
                        )
                    );
                  }
              ),
              ListTile(
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
          title: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            MaterialButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
            ),
            MaterialButton(
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
    //TODO: FACTOR
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


    try {
      final http.Response response = await http.put( //register to database
          'https://dogsonfire.herokuapp.com/users',
          headers: <String, String>{
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${await AuthService()
                .getCurrentFirebaseUser()
                .then((value) =>
                value.getIdToken().then((value) => value.token))}'
          },
          body: jsonEncode(<String, String>{
            "dateOfBirth": dateOfBirth,
          })
      );

      if (response.statusCode == 200) { // Successfully created database account
        print(response.statusCode);

        setState(() {
          widget.user.setDateOfBirth(dateOfBirth);
        });
      } else { //Something went wrong
        print(response.statusCode);
        print(response.body);
      }
    } catch (e) {
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

  _setGender(String gender) async {
    if (gender == "-") {
      gender = "UNKNOWN";
    }

    try {
      final http.Response response = await http.put(
          'https://dogsonfire.herokuapp.com/users',
          headers: <String, String>{
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${await AuthService()
                .getCurrentFirebaseUser()
                .then((value) =>
                value.getIdToken().then((value) => value.token))}'
          },
          body: jsonEncode(<String, String>{
            "gender": gender,
          })
      );

      if (response.statusCode == 200) {
        print(response.statusCode);
        setState(() {
          widget.user.setGender(gender);
        });
      } else { //Something went wrong
        print(response.statusCode);
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

}