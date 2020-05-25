import 'package:dog_prototype/models/Dog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DogProfile extends StatefulWidget {

  final Dog dog;
  DogProfile({this.dog});

  @override
  _DogProfileState createState() => _DogProfileState();
}

class _DogProfileState extends State<DogProfile> {

  ProfileState _state = ProfileState.About;

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
            Text('picture')
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
        Text("DOG1", style: TextStyle(fontSize: 20.0),),
        Padding(padding:EdgeInsets.only(top: 10.0)),
        Text("Owner: " + "user"),
        Text("Breed: " + "Bulldog"),
        Text("Age: " + "5"),
        Text("Gender: " + "Male"),
        Text("Castrated: " + "Yes"),
        Text("Description: " + "Dog1 loves to be a test dog"),
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

}

enum ProfileState{About, Awards}