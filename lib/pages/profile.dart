import 'package:dog_prototype/pages/dogProfile.dart';
import 'package:dog_prototype/pages/placeHolderHome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  String name = 'Anders';
  List<String> dognames = ['Fido', 'Flurdo', 'Flermo'];
  List<String> images = [
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage('assets/pernilla.jpg'),
              ),
              title: Text(name),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: <Widget>[Text('My dogs: ')],
            ),
          ),

          //dogs

          Expanded(
            flex: 12,
            child: ListView.builder(
              itemCount: dognames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.pets),
                  title: Text(dognames[index]),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DogProfile()));
                  },
                );
              },
            ),
          ),
          Expanded(
              flex: 2,
              child: Row(
                children: <Widget>[
                  Text(
                    'My pictures:',
                  ),
                ],
              )),
          Expanded(
            flex: 22,
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
          ),
        ],
      ),
    );
  }
}
