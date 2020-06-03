import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;

class DogProfileViewer extends StatefulWidget {

  final Dog dog;
  DogProfileViewer({this.dog});

  @override
  _DogProfileViewerState createState() => _DogProfileViewerState();
}

class _DogProfileViewerState extends State<DogProfileViewer> {
  Dog dog;
  String profileImage;
  bool _loadingImage = false;

  @override
  void initState() {
    if(dog == null){
      dog = widget.dog;
    }
    _getProfileImage();
    super.initState();
  }

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if(profileImage == null){
      return DefaultLoader();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Dog Profile'),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        progressIndicator: DefaultLoader(),
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pictureSection(),
              _informationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pictureSection(){
    return Expanded(
      flex: 2,
      child: Center(
        child: Column(
            children: [
              _loadingImage == true ?
                  DefaultLoader()
              :
              Container(
                height: 80,
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10000.0),
                  child: CachedNetworkImage(
                      imageUrl: profileImage,
                      placeholder: (context, url) => DefaultLoader(),
                      errorWidget: (context, url, error) => CircleAvatar(radius: 40, child: Icon(Icons.image, color: Colors.white), backgroundColor:Colors.grey)),
                ),
              ),
              Padding(padding: EdgeInsets.only(top:25.0)),
            ],
        ),
      )
    );
  }

  Widget _informationSection() {
    return Expanded(
     flex: 8,
     child: Column(
       children: [
         Expanded(
           flex: 7,
           child: aboutSection()
         ),
         Expanded(
           flex: 3,
             child: _descriptionSection()
         ),
       ],
     )
    );
  }

  Widget aboutSection(){
    if(dog.gender == 'MALE'){
    return ListView(
      children: ListTile.divideTiles(
        context: context,
          tiles: [
            ListTile(
                title: Text('Name:'),
                trailing: Text(dog.name ?? 'No name specified.'),
            ),
            ListTile(
                title: Text('Breed:'),
                trailing: Text(dog.breed ?? 'No breed specified.'),
            ),
            ListTile(
                title: Text('Date of birth:'),
                trailing: Text(dog.dateOfBirth ?? 'No date of birth specified.'),
            ),
            
            ListTile(
                title: Text('Neutered:'),
                trailing: Text((dog.getNeutered()),
            )),
            ListTile(
                title: Text('Gender:'),
                trailing: Text(dog.gender)
            ),
          ]
      ).toList(),
    );
    } else{ 
    return ListView(
      children: ListTile.divideTiles(
        context: context,
          tiles: [
            ListTile(
                title: Text('Name:'),
                trailing: Text(dog.name ?? 'No name specified.'),
            ),
            ListTile(
                title: Text('Breed:'),
                trailing: Text(dog.breed ?? 'No breed specified.'),
            ),
            ListTile(
                title: Text('Date of birth:'),
                trailing: Text(dog.dateOfBirth ?? 'No date of birth specified.'),
            ),
            ListTile(
                title: Text('Gender:'),
                trailing: Text(dog.gender)
            ),
          ]
      ).toList(),
    );
  }
  }

  Widget _descriptionSection(){
    return ListView(
      children: [
        ListTile(
          title: Text('Description', style: TextStyle(fontSize: 20)),
        ),
        Text(dog.description ?? 'This dog does not seem to have a description yet' ),
      ],
    );
  }

  _getProfileImage() async{
    String token = await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token));
    try{
      final url = await http.get('https://dogsonfire.herokuapp.com/images/${dog.uuid}', headers:{'Authorization': 'Bearer $token'});
      if(url.statusCode==200){
        setState(() {
          profileImage = url.body;
        });
      }
      setState(() {
        _loadingImage = false;
      });
    }catch(e){
      print(e);
      setState(() {
        _loadingImage = false;
      });
    }
  }

}