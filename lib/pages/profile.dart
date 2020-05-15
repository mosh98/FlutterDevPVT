import 'dart:collection';
import 'dart:convert';

import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/Settings.dart';
import 'package:dog_prototype/pages/dogProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Map<int, String> _userDogs = new HashMap<int, String>();

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
    _getUserDogs();
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
        return Center(child:DefaultLoader());
      },
    );
  }

  Widget _profileBuilder(User user){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Profile'),
        centerTitle: true,
        actions: <Widget>[
          FlatButton.icon(
            onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage(user: user)));
            },
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            label: Text(
              'Settings',
              style: TextStyle(color:Colors.white),
            ),
          ),
        ],
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
              leading: GestureDetector(
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('assets/pernilla.jpg'),
                ),
                onTap: (){},
              ),
              title: Text(user.username),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection(User user){
    return Expanded(
        flex: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('About', style: TextStyle(fontSize: 16)),
            Padding(padding: EdgeInsets.only(top:10),),
            Text(user.desc),
            Padding(padding: EdgeInsets.only(top:10),),
            Row(
              children: <Widget>[
                Text('My dogs:', style: TextStyle(fontSize: 17)),
                IconButton(icon: Icon(Icons.add),onPressed: (){_addDog(user);},iconSize: 16)
              ],
            ),
            _dogBuilder(user)
          ],
        )
    );
  }

  void _addDog(User user) async{

    String dogName = "";

    await showDialog(context: context,
    child: AlertDialog(
    title: Text('What is the name of your dog?'),
    content: SingleChildScrollView(
    child: TextFormField(
    onChanged: (value){dogName = value;},
    ),
    ),
    actions: <Widget>[
    MaterialButton(
    child: Text('Add dog'),
    onPressed: (){Navigator.of(context).pop();},
    ),
    MaterialButton(
    child: Text('Back'),
    onPressed: (){Navigator.of(context).pop(); return;},
    )
    ],
    )
    );

    print(dogName);

    if(dogName.isEmpty){
      return;
    }
    
    final http.Response response = await http.post(
        'https://redesigned-backend.herokuapp.com/user/dog/register?owner=${user.username}',
        headers:<String, String>{
          'Content-Type' : 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String,String>{
          'name':dogName,
          'age':null,
          'breed':'Not set',
          'gender':'Not set',
          'description':'not set',
        })
    );

    if(response.statusCode==200){
      print(response.body);
    }else{
      print('semething wrong');
    }
  }

  Future<String> getNewDogName() async{
    String dogName = "";

    AlertDialog alert = AlertDialog(
      title: Text('What is the name of your dog?'),
      content: SingleChildScrollView(
        child: TextFormField(
          onChanged: (value){dogName = value;},
        ),
      ),
      actions: <Widget>[
        MaterialButton(
          child: Text('Add dog'),
          onPressed: (){Navigator.of(context).pop();},
        ),
        MaterialButton(
          child: Text('Back'),
          onPressed: (){Navigator.of(context).pop(); return;},
        )
      ],
    );
    showDialog(context: context, builder: (BuildContext context){return alert;});

    return dogName;
  }

  Widget _dogBuilder(User user){
    return Expanded(
      flex: 12,
      child: ListView.builder(
        itemCount: _userDogs.values.toList().length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.pets),
            title: Text(_userDogs.values.toList()[index]),
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => DogProfile()));
              });
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

    final response = await http.get('https://redesigned-backend.herokuapp.com/user/find?username=$username');

    if(response.statusCode == 200){
      User test = User.fromJson(json.decode(response.body));
      List<dynamic> dogs = test.dogs;
      print(dogs.toString());
      return User.fromJson(json.decode(response.body));
    }else{
      print(username);
      throw Exception('Failed to load user');
    }
  }

  //TODO: ADD URL TO MAP FOR PICTURE
  void _getUserDogs() async{
    final response = await http.get('https://redesigned-backend.herokuapp.com/user/getMyDogs?username=usernametest');

    if(response.statusCode == 200){
      List<dynamic> dogs = jsonDecode(response.body);
      dogs.forEach((element) {
        setState(() {
          _userDogs.putIfAbsent(element['dogId'], () => element['name']);
        });
      });
    }else{
      throw Exception('Failed to load user');
    }
  }
}