import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DogProfile extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new DogPage(),
    );
  }
}

class DogPage extends StatefulWidget{
  @override
  State createState() => new DogPageState();
}

class DogPageState extends State<DogPage>{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(40.0),
        children: <Widget>[
          Center(child: new Text('DogName')),
          Image(
            image: new AssetImage('assets/loginpicture.jpg'),
            height: 100.0,
            width: 50.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ButtonBar(
                children: <Widget>[
                  FlatButton.icon(
                      onPressed: (){},
                      icon: Icon(Icons.person, size: 70,),
                      label: Text('About'),
                      textColor: Colors.black,

                  ),
                  FlatButton.icon(
                      onPressed: (){},
                      icon: Icon(Icons.picture_in_picture,size: 70,),
                      label: Text('Pictures'),
                      textColor: Colors.black
                  ),
                ],
              ),
            ],
          ),
        ],
      )
    );
  }
}

void _dogAbout(){

}

void _dogPictures(){

}