import 'package:dog_prototype/pages/friends.dart';
import 'package:dog_prototype/pages/mapPage.dart';
import 'package:dog_prototype/pages/messages.dart';
import 'package:dog_prototype/pages/profile.dart';
import 'package:dog_prototype/pages/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions = <Widget>[
    ProfilePage(),
    MapPage(),
    Search(),
    Messages()


  ];
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_circle), title: Text('Profile')),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on),
          title: Text('Maps'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          title: Text('Search'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          title: Text('Messages'),

        ),
      ],
      currentIndex: _selectedIndex,
    );
  }
}
