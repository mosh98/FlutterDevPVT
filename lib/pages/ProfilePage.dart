import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/SettingsPage.dart';
import 'package:dog_prototype/pages/profileDog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget{

  final User user;
  ProfilePage({this.user});

  @override
  State createState() => new ProfileState();
}

class ProfileState extends State<ProfilePage>{

  File _image;

  List<String> images = [ //TODO: DELETE AFTER FIXED PICTURES.
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
  ];

  @override
  void initState() {
    super.initState();
  }

  Widget _loading = CircularProgressIndicator();

  @override
  Widget build(BuildContext context) {
    if(widget.user == null){
      return _loading;
    }else{
      return profile();
    }
  }

  Widget profile(){

    print(widget.user.toString());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Profile'),
        centerTitle: true,
        actions: <Widget>[
          FlatButton.icon(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage(user: widget.user)));
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
          _headerSection(),

          _infoSection(),

          _pictureSection(),
        ],
      ),
    );
  }

  Widget _headerSection(){
    return Expanded(
      flex: 2,
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            GestureDetector(
                onTap: getImage,
                child: _image == null
                    ? CircleAvatar(radius: 40, child: Icon(Icons.add_a_photo, color: Colors.white), backgroundColor:Colors.grey)
                    : CircleAvatar(radius: 40, backgroundImage: FileImage(_image))
            ),
            Padding(padding: EdgeInsets.only(left: 10),),
            Text(widget.user.username, style: TextStyle(fontSize: 16),)
          ],
        ),
      ),
    );
  }

  Widget _infoSection(){
    return Expanded(
        flex: 6,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('About', style: TextStyle(fontSize: 16)),
              Padding(padding: EdgeInsets.only(top:10),),
              Text(widget.user.desc ?? 'Add a description of yourself'),
              Padding(padding: EdgeInsets.only(top:10),),
              Row(
                children: <Widget>[
                  Text('My dogs:', style: TextStyle(fontSize: 17)),
                  IconButton(icon: Icon(Icons.add),onPressed: (){_addDog();},iconSize: 16)
                ],
              ),
              _dogSection()
            ],
          ),
        )
    );
  }

  Widget _dogSection(){
    return Expanded(
      flex: 12,
      child: ListView.builder(
        itemCount: widget.user.dogs.length,
        itemBuilder: (context, index) {
          return ListTile(
              leading: Icon(Icons.pets),
              title: Text(widget.user.dogs[index]['name']),
              //TODO: IMAGE URL
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => DogProfile()));
              });
        },
      ),
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

  void _addDog() async{

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
      String token = await AuthService().getCurrentFirebaseUser().then((firebaseUser) => firebaseUser.getIdToken().then((tokenResult) => tokenResult.token));
      print(token);
      final http.Response response = await http.put(
          'https://dogsonfire.herokuapp.com/dogs/',
          headers:{
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String,String>{
            'name':dogName,
            'breed':null,
            'dateOfBirth':null,
            'gender':null,
            'neutered':null,
            'description':null,
          })
      );

      if(response.statusCode==200){
        setState(() {});
      }else{
        print(response.statusCode);
        print(response.body);
      }
    }catch(e){
      print(e);
    }
  }

  Future getImage() async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
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

