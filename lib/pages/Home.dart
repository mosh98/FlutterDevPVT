import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/FindFriends.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/services/HttpProvider.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ProfilePage.dart';
import 'mapPage.dart';
import 'messages.dart';

class App extends StatefulWidget {

  final Future<User> futureUser;
  final User user;
  final StorageProvider storageProvider;
  final HttpProvider httpProvider;
  final AuthService authService;
  App({this.futureUser, this.user, this.storageProvider, this.httpProvider, this.authService});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<App> {
  MapPage mapPage;
  ProfilePage profilePage;
  Messages messages;
  FindFriends search;
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
      profilePage = ProfilePage(user:user,storageProvider: widget.storageProvider, httpProvider: widget.httpProvider, authService: widget.authService,);
      messages = Messages(user: user, storageProvider: widget.storageProvider,);
      search = FindFriends(user: user,storageProvider: widget.storageProvider,httpProvider: widget.httpProvider,authService: widget.authService,);
      pages = [profilePage, mapPage, search, messages];
      currentPage = pages[selectedIndex];
    }
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.person_pin_circle),
              title: Text('Profile',key: Key('profile'),)),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            title: Text('Maps', key:Key('maps')),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Find friends', key:Key('findfriends')),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text('Messages', key:Key('messages')),
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
