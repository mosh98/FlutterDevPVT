import 'dart:io';

import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/Dog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class DogProfileViewer extends StatefulWidget {

  final Dog dog;
  DogProfileViewer({this.dog});

  @override
  _DogProfileViewerState createState() => _DogProfileViewerState();
}

class _DogProfileViewerState extends State<DogProfileViewer> {

  ProfileState _state = ProfileState.About;
  File _image;
  Dog dog;

  @override
  void initState() {
    if(dog == null){
      dog = widget.dog;
    }
    super.initState();
  }

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Dog Profile'),
        centerTitle: true,
      ),
      backgroundColor: Colors.brown[100],
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
    //TODO, WHEN PICTURES IS FINISHED
    return Expanded(
      flex: 2,
      child: Center(
        child: Column(
            children: [
              GestureDetector(
                  //onTap: getImage,
                  child: _image == null
                      ? CircleAvatar(radius: 40, child: Icon(Icons.add_a_photo, color: Colors.white), backgroundColor:Colors.grey)
                      : CircleAvatar(radius: 40, backgroundImage: FileImage(_image))
              ),
              Padding(padding: EdgeInsets.only(top:25.0)),
              _stateSection()
            ],
        ),
      )
    );
  }

  Widget _stateSection(){
    return DefaultTabController(
        length: 2,
        child: TabBar(
            labelColor: Colors.black,
            onTap: (value){
              if(value==0){
                setState(() {
                  _state = ProfileState.About;
                });
              }else{
                setState(() {
                  _state = ProfileState.Awards;
                });
              }
            },
            indicatorWeight: 0.1,
            unselectedLabelColor: Colors.grey,
            tabs: <Widget>[
              Tab(
                  icon: Icon(Icons.person),
                  child:Text('About')
              ),
              Tab(
                  icon: Icon(Icons.star),
                  child:Text('Awards')
              )
            ]
        )
    );
  }

  Widget _informationSection() {
    return Expanded(
     flex: 4,
     child: Column(
       children: [
         Expanded(
           flex: 7,
           child: _state == ProfileState.About ?
           aboutSection()
               :
           awardsSection(),
         ),
         Expanded( //TODO
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

  Widget awardsSection(){
    return Column(
      children: [
        Text('IF WE HAVE TIME TO IMPLEMENT THIS')
      ],
    );
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

}
  enum ProfileState{About, Awards}