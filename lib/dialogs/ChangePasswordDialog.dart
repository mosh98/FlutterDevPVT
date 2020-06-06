import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/material.dart';

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