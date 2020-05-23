import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {

  final User user;
  SettingsPage({this.user});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
          child: CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/pernilla.jpg'),
          ),
          onLongPress: (){print('clicked profile picture');},
        ),
      ),
    );
  }

  Widget _profileInformationBuilder(){
    return Expanded(
        flex:5,
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              GestureDetector(
                child: ListTile(
                  title: Text('Username'),
                  trailing: Text(widget.user.username ?? 'No username.'),
                ),
                onLongPress: (){print('clicked username');},
              ),
              GestureDetector(
                child: ListTile(
                    title: Text('Email'),
                    trailing: Text(widget.user.email ?? 'No email')
                ),
                onLongPress: (){},
              ),
              GestureDetector(
                child: ListTile(
                  title: Text('Date of birth'),
                  trailing: Text(widget.user.dateOfBirth ?? 'No date of birth'),
                ),
                onLongPress: (){print('clicked date of birth');},
              ),
              GestureDetector(
                child: ListTile(
                  title: Text('Gender'),
                  trailing: Text(widget.user.gender ?? 'No gender specified'),
                ),
                onLongPress: (){print('clicked gender');},
              ),
              GestureDetector(
                child: ListTile(
                  title: Text('Member since'),
                  trailing: Text(widget.user.createdDate ?? 'No creation Date specified'),
                  onLongPress: (){print('clicked member');},
                ),
              ),
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
                onLongPress: (){print('clicked change password');},
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
}