import 'dart:collection';
import 'dart:convert';

import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/dogProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class profileViewer extends StatefulWidget{

  @override
  ProfileState createState() => ProfileState();

    profileViewer({@required this.userName});
    final String userName;
}

class ProfileState extends State<profileViewer>{

Map<int, String> _userDogs = new HashMap<int, String>();
List<String> images = [ //TODO: DELETE AFTER FIXED PICTURES.
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
  ];

  get userName => widget.userName;

  @override
  void initState(){
    super.initState();
    _getUserDogs();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userBuilder(),
      builder: (context, snapshot){
        if(snapshot.hasData){
          return _profile(snapshot.data);
        }else if(snapshot.hasError){
          return Center(child:Text("${snapshot.error}"));
        }
        return Center(child:DefaultLoader());
      },
    );
  }

  Widget _profile(User user){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Profile'),
        centerTitle: true,
        actions: <Widget>[
          FlatButton.icon(
            onPressed: (){
                //Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage(user: user)));
            },
            icon: Icon(
              Icons.person_add,
              color: Colors.white,
            ),
            label: Text(
              'Add Friend',
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
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            CircleAvatar( //TODO: onbackgroundimageerror
              radius: 25,
              backgroundImage: AssetImage('assets/pernilla.jpg'),
            ),
            Padding(padding: EdgeInsets.only(left: 10),),
            Text(user.username, style: TextStyle(fontSize: 16),)
          ],
        ),
      ),
    );
  }

  Widget _infoSection(User user){
    return Expanded(
        flex: 6,
        child: Container(
          padding: EdgeInsets.all(15),
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
                ],
              ),
              _dogBuilder(user)
            ],
          ),
        )
    );
  }

  Widget _pictureSection(){
    return Expanded(
      flex: 2,
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        itemCount: images.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          return (
              GestureDetector(
              onTap: () 
                async {
              await showDialog(
                context: context,
                builder: (_) => ImageDialog()
              );
              },
              child: Image(
              image: AssetImage(images[index]),
          ),
          )
          );
        },
      ),
    );
  }

  /*

Image(
            image: AssetImage(images[index]),
          ))

() async {
              await showDialog(
                context: context,
                builder: (_) => ImageDialog()
              );
            },
          ),

  */

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

    if(dogName.isEmpty){
      return; //todo. error message
    }
    
    try{
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
    }catch(e){
      print(e);
    }
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

  Future<User> _userBuilder() async{
    var username = userName;

    try{
      final response = await http.get('https://redesigned-backend.herokuapp.com/user/find?username=$username');

      if(response.statusCode == 200){
        return User.fromJson(json.decode(response.body));
      }else{
        throw Exception('Failed to load user');
      }
    }catch(e){
      print(e);
      return null;
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

class ImageDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ExactAssetImage('assets/pernilla.jpg'),
            fit: BoxFit.cover
          )
        ),
      ),
    );
  }
}