import 'dart:io';

import 'package:dog_prototype/models/Dog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DogProfile extends StatefulWidget {

  final Dog dog;
  DogProfile({this.dog});

  @override
  _DogProfileState createState() => _DogProfileState();
}

class _DogProfileState extends State<DogProfile> {

  ProfileState _state = ProfileState.About;
  File _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Dog Profile'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(15.0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pictureSection(),
              _stateSection(),
              _informationSection(),
            ],
        )
      ),
    );
  }

  Widget _pictureSection(){
    //TODO, WHEN PICTURES IS FINISHED
    return Expanded(
      flex: 2,
      child: Column(
          children: [
            GestureDetector(
                onTap: getImage,
                child: _image == null
                    ? CircleAvatar(radius: 40, child: Icon(Icons.add_a_photo, color: Colors.white), backgroundColor:Colors.grey)
                    : CircleAvatar(radius: 40, backgroundImage: FileImage(_image))
            ),
          ],
      )
    );
  }

  Widget _stateSection(){
    return Expanded(
      flex: 1,
      child: DefaultTabController(
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
      )
    );
  }

  Widget _informationSection() {
    return Expanded(
     flex: 7,
     child: _state == ProfileState.About ?
     aboutSection()
         :
     awardsSection()
    );
  }

  Widget aboutSection(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.dog.name, style: TextStyle(fontSize: 20.0),),
        Padding(padding:EdgeInsets.only(top: 10.0)),
        Text(widget.dog.breed == null ? 'Breed: Unknown.' : 'Breed: ' + widget.dog.breed),
        Text(widget.dog.dateOfBirth == null ? 'Date of birth: Unknown.' : 'Date of birth: ' + widget.dog.dateOfBirth),
        Text(widget.dog.gender == null ? 'Gender: Unknown.' : 'Gender: ' + widget.dog.gender),
        Text(widget.dog.neutered == null ? 'Neutered: Unknown.' : 'Neutered: ' + widget.dog.neutered.toString()),
        Text(widget.dog.description == null ? 'Description: Unknown.' : 'Description: ' + widget.dog.description),
      ],
    );
  }

  Widget awardsSection(){
    return Column(
      children: [
        Text('IF WE HAVE TIME TO IMPLEMENT THIS')
      ],
    );
  }

  Future getImage() async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

}

enum ProfileState{About, Awards}