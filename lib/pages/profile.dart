import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'StartPage.dart';

class ProfilePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return StatefulProfile();
  }
}

class StatefulProfile extends StatefulWidget{
  @override
  State createState() => new ProfileState();
}

class ProfileState extends State<StatefulProfile>{

  Future<User> _user;
  List<dynamic> dogNames;
  SharedPreferences prefs;
  static const List<String> settingsOptions = <String>['Sign out'];

  //TODO: REMOVE FAKEDATA AND FETCH REAL DATA FROM DATABASE
  List<String> dognames = ['Fido', 'Flurdo', 'Flermo'];
  List<String> images = [
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
  ];
  //TODO

  @override
  void initState(){
    super.initState();
    _user = _buildUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _user,
      builder: (context, snapshot){
        if(snapshot.hasData){
          return _profileBuilder(snapshot.data);
        }else if(snapshot.hasError){
          return Center(child:Text("${snapshot.error}"));
        }
        return Center(child:CircularProgressIndicator());
      },
    );
  }

  Widget _profileBuilder(User user){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _headerSection(user),


          _infoSection(user),

          _pictureSection(),
        ],
      ),
    );
  }

  Widget _headerSection(User user){
    return Expanded(
      flex: 2,
      child: Row(
        children: <Widget>[
          Expanded(
            flex:7,
            child:ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage('assets/pernilla.jpg'),
              ),
              title: Text(user.username),
            ),
          ),
          Expanded(
              flex:3,
              child:DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  items: settingsOptions.map((String option){
                    return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option)
                    );
                  }).toList(),
                  icon: Icon(Icons.settings),
                  onChanged: (String option) {
                    setState(() {
                      _settingsAction(option);
                    });
                  },
                  isExpanded: false,
                ),
              )
          ),
        ],
      ),
    );
  }

  void _settingsAction(String action) async{
    if(action == 'Sign out'){
      prefs = await SharedPreferences.getInstance();
      prefs.clear();
      prefs.reload();
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => StartPage()), (Route<dynamic> route) => false);
    }
  }

  Widget _infoSection(User user){
    return Expanded(
        flex: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('About', style: TextStyle(fontSize: 16)),
            Padding(padding: EdgeInsets.only(top:10),),
            Text('Hardcoded desc'),
            Padding(padding: EdgeInsets.only(top:10),),
            Row(
              children: <Widget>[
                Text('My dogs:', style: TextStyle(fontSize: 17)),
                IconButton(icon: Icon(Icons.add),onPressed: (){_registerDog();},iconSize: 16)
              ],
            ),
            _dogBuilder(user)
          ],
        )
    );
  }

  Widget _dogBuilder(User user){
    return Expanded(
      flex: 12,
      child: ListView.builder(
        itemCount: user.dogs.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.pets),
            title: Text(''),
          );
        },
      ),
    );
  }

  Widget _pictureSection(){
    return Expanded(
      flex: 4,
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        itemCount: images.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          return (Image(
            image: AssetImage(images[index]),
          ));
        },
      ),
    );
  }

  Future<User> _buildUser() async{
    final prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username');

    final response = await http.get('https://pvt-dogpark.herokuapp.com/user/find?name=$username');

    if(response.statusCode == 200){
      User test = User.fromJson(json.decode(response.body));
      dogNames = test.dogs;
      print(dogNames);
      return User.fromJson(json.decode(response.body));
    }else{
      throw Exception('Failed to load user');
    }
  }

  void _registerDog(){
    //TODO
  }
}

class User{
  final String username;
  final List<dynamic> dogs;

  User({this.username, this.dogs});

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      username: json['username'],
      dogs: json['dogs'],
    );
  }
}

class Dog{
  final String name;
  final String owner;

  Dog({this.name, this.owner});

  factory Dog.fromJson(Map<String, dynamic> json){
    return Dog(
      name: json['name'],
      owner: json['owner'],
    );
  }
}