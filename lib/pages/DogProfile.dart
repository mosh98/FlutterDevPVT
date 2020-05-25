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

  final ProfileState _state = ProfileState.About;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          children: [
            _pictureSection(),
            _stateSection(),
            _informatioSection(),
          ],
        )
      ],
    );
  }

  Widget tesst(){
    return DefaultTabController(
      length: 2,
      child: TabBar(
        tabs: <Widget>[
          Tab(

          ),
          Tab(

          )
        ],
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
      child: Row(
        children: [
          Text('statesection')
        ],
      ),
    );
  }

  Widget _informatioSection() {
    return Expanded(
     flex: 7,
     child: Column(
       children: [
         Text('informationssection')
       ],
     )
    );
  }

}

enum ProfileState{About, Awards}