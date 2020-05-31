import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/services/Validator.dart';
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
  Widget _loading = DefaultLoader();
  bool _loadingProfile = false;
  String snackText = "";
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
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
                trailing: Text(widget.user.email ?? 'No email'),
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
        flex: 2,
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
                          context: context, scaffoldKey: _scaffoldKey,));
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

enum DeleteAccountState{Decision, AuthenticatedConfirm}

class DeleteAccountDialog extends StatefulWidget {

  final BuildContext context;
  final scaffoldKey;
  DeleteAccountDialog({this.context, this.scaffoldKey});

  @override
  _DeleteAccountDialogState createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {

  DeleteAccountState state = DeleteAccountState.Decision;
  String snackText = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return _showDialog();
  }

  Widget _showDialog(){
    return SimpleDialog(
        contentPadding: EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))
        ),
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: state == DeleteAccountState.Decision ?
                Text(
                  'Are you sure that you want to delete your profile? This is not reversible',
                  style: TextStyle(fontSize: 17),
                )
                    :
                Text(
                  'Enter your password to confirm account deletion:',
                  style: TextStyle(fontSize: 17),
                ),
              ),
              if(state==DeleteAccountState.AuthenticatedConfirm)
                TextField(
    decoration: InputDecoration(hintText: 'Password*'),
    onChanged: (String pass){password = pass;},
    obscureText: true,
    ),
              Padding(
                padding: EdgeInsets.only(top:20),
                child: state == DeleteAccountState.Decision ?
                ListTile(
                    leading: RaisedButton(
                        child: Text('No'),
                        onPressed: (){Navigator.pop(context);},
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)))
                    ,
                    trailing: RaisedButton(
                        child: Text('Yes'),
                        onPressed: (){
                          setState(() {
                            state = DeleteAccountState.AuthenticatedConfirm;
                          });
                        },
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)))
                )
                    :
                ListTile(
                    leading: RaisedButton(
                        child: Text('Back'),
                        onPressed: (){Navigator.pop(context);},
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)))
                    ,
                    trailing: RaisedButton(
                        child: Text('Delete'),
                        onPressed: (){
                          _authenticate(password);
                          Navigator.pop(context);
                        },
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)))
                ),
              ),
            ],
          ),
        ],
      );
  }

  void _authenticate(String password) async{
    dynamic authenticated = await AuthService().reauthenticateUser(password);
    if(authenticated != null){
      _deleteAccount();
    }else{
      snackText = "Password was incorrect.";
      widget.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText),));
    }
  }

  void _deleteAccount() async{
    bool deletedAccount = await AuthService().deleteAccount();
    if(deletedAccount){
      snackText = "Deleting account.";
      widget.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText),));
      await Future.delayed(Duration(seconds:4));
      Navigator.of(widget.context).popUntil((route) => route.isFirst);
    }else{
      snackText = "Something went wrong with deleting your account.";
      widget.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText),));
    }
  }
}

enum ChangePasswordState{Authenticate, NewPassword}

class ChangePasswordDialog extends StatefulWidget {

  final BuildContext context;
  final scaffoldKey;
  ChangePasswordDialog({this.context, this.scaffoldKey});

  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {

  ChangePasswordState state = ChangePasswordState.Authenticate;
  String snackText = "";

  @override
  Widget build(BuildContext context) {
    return _showDialog();
  }

  Widget _showDialog(){

    String password = "";

    return SimpleDialog(
      contentPadding: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: state == ChangePasswordState.Authenticate ?
              Text(
                'Enter your current password:',
                style: TextStyle(fontSize: 17),
              )
                  :
              Text(
                'Authenticated. Enter a new password:',
                style: TextStyle(fontSize: 17),
              ),
            ),
            TextFormField(
              onChanged: (String newPassword){password = newPassword;},
              obscureText: true,
            ),
            Padding(
              padding: EdgeInsets.only(top:20),
              child: ListTile(
                  leading: RaisedButton(
                      child: state == ChangePasswordState.Authenticate ?
                      Text('Enter') : Text('Renew'),
                      onPressed: ()async{
                        state == ChangePasswordState.Authenticate ? await _authenticate(password) : await _renewPassword(password);
                      },
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)))
                  ,
                  trailing: RaisedButton(
                      child: Text('Back'),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)))
              ),
            ),
          ],
        ),
      ],
    );
  }

  _authenticate(String password) async{
    dynamic reAuthenticated = await AuthService().reauthenticateUser(password);

    if(reAuthenticated != null){
      setState(() {
        state = ChangePasswordState.NewPassword;
      });
    }else{
      snackText = "The password you entered was incorrect.";
      widget.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText),));
      Navigator.pop(context);
    }
  }

  _renewPassword(String password) async{
    dynamic renewedPassword = await AuthService().changePassword(password);
    if(renewedPassword == true){
      snackText = "Your password has been updated. Signing out.";
      widget.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText),));
      await Future.delayed(Duration(seconds:4));
      AuthService().signOut();
      Navigator.of(widget.context).popUntil((route) => route.isFirst);
    }else{
      snackText = "Something went wrong with updating your password.";
      widget.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText),));
      Navigator.pop(context);
    }
  }
}

