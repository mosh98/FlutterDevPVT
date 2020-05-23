import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ProfilePage.dart';
import 'mapPage.dart';
import 'messages.dart';

class PlaceHolderApp extends StatefulWidget {

  final Future<User> futureUser;
  PlaceHolderApp({this.futureUser});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<PlaceHolderApp> {
  MapPage mapPage;
  ProfilePage profilePage;
  Messages messages;
  Search search;
  List<Widget> pages;
  Widget currentPage;
  int selectedIndex = 0;

  @override
  void initState() {
    mapPage = MapPage();
    profilePage = ProfilePage(futureUser:widget.futureUser);
    messages = Messages();
    search = Search();
    pages = [profilePage, mapPage, search, messages];
    currentPage = pages[selectedIndex];
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

  void setHomePageState(Widget currentPage){
    this.currentPage = currentPage;
  }
}
