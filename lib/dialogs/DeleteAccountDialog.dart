import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/material.dart';

enum DeleteAccountState{Decision, AuthenticatedConfirm}

class DeleteAccountDialog extends StatefulWidget {

  final BuildContext context;
  final scaffoldKey;
  final ProviderState provider;
  DeleteAccountDialog({this.context, this.scaffoldKey, this.provider});

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
    if(widget.provider == ProviderState.FacebookUser){
    _deleteAccount();
    Navigator.pop(context);
    }
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