import 'package:dog_prototype/pages/profile.dart';
import 'package:dog_prototype/pages/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'mapPage.dart';
import 'messages.dart';
import 'StartPage.dart';

class PlaceHolderApp extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<PlaceHolderApp> {
  MapPage mapPage;
  ProfilePage profilePage;
  Messages messages;
  Search search;
  StartPage start;
  List<Widget> pages;
  Widget currentPage;
  int selectedIndex = 0;

  @override
  void initState() {
    mapPage = MapPage();
    profilePage = ProfilePage();
    messages = Messages();
    search = Search();
    start = StartPage();

    //TODO: LA IN LOGIN-PAGE MEN VET INTE HUR JAG SKA FÅ DET SOM HOMEPAGE.
    pages = [profilePage, mapPage, search, messages];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
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
        currentIndex: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
            currentPage = pages[index];
          });
        },
      ),
      body: currentPage,
    );
  }
}
