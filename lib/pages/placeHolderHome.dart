import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/search.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ProfilePage.dart';
import 'mapPage.dart';
import 'messages.dart';

class PlaceHolderApp extends StatefulWidget {

  final Future<User> futureUser;
  final User user;
  PlaceHolderApp({this.futureUser, this.user});

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

  User user;

  @override
  void initState() {
    if(widget.user == null){
      _getUserModel();
    }else{
      user = widget.user;
    }
    super.initState();
  }

  _getUserModel() async{
    user = await widget.futureUser;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    if(user == null){
      return DefaultLoader();
    }else{
      mapPage = MapPage();
      profilePage = ProfilePage(user:user);
      messages = Messages();
      search = Search();
      pages = [profilePage, mapPage, search, messages];
      currentPage = pages[selectedIndex];
    }
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
