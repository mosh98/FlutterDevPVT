import 'package:dog_prototype/elements/profileDescriptorTile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DogProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Dog Profile"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 6, child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index){
              return Padding(
                padding: EdgeInsets.only(left: 5),
                child: Image(image: AssetImage('assets/pernilla.jpg'),),
              );
            },
          )),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.directions_run),
                      onPressed: () {},
                    ),
                    Text('Routes')
                  ],
                ),
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.person),
                      onPressed: () {},
                    ),
                    Text('Owner')
                  ],
                ),
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.favorite),
                      onPressed: () {},
                    ),
                    Text('Preferences')
                  ],
                ),
              ],
            ),
          ),
          Expanded(
              flex: 10,
              child: ListView.separated(
                  itemCount: 5,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(),
                  itemBuilder: (context, index) {
                    return ProfileDescriptorTile();
                  }))
        ],
      ),
    );
  }
}
