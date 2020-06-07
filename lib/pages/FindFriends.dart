import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dog_prototype/loaders/CustomLoader.dart';
import 'package:dog_prototype/pages/MessengerHandler.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/services/HttpProvider.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dog_prototype/models/User.dart';

import 'profileViewer.dart';

class FindFriends extends StatefulWidget {

  final User user;
  final StorageProvider storageProvider;
  final HttpProvider httpProvider;
  final AuthService authService;
  FindFriends({this.user, this.storageProvider, this.httpProvider,this.authService});

  @override
  FindFriendsState createState() => FindFriendsState(currentUser:this.user);
}

class FindFriendsState extends State<FindFriends> {

  FindFriendsState({this.currentUser});
  Map<User, String> users = new Map<User, String>();
  User currentUser;
  final textFieldController = TextEditingController();
  bool _loading = false;
  CustomLoader loader = CustomLoader(textWidget: Text("Finding friends.."),);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        centerTitle: true,
        title: Text('Find friends'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              key: Key('search'),
                decoration: InputDecoration(hintText: "Search"),
                keyboardType: TextInputType.text,
                controller: textFieldController,
                onSubmitted: (String input) {
                  setState(() {
                    _loading = true;
                  });
                  _getUser(input);
                }),
          ),
          _loading == true ?
          Expanded(child: loader,)
              :
          Expanded(
            child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  User user = users.keys.elementAt(index);

                  return GestureDetector(
                    onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileViewer(otherUser: user, currentUser:widget.user,storageProvider: widget.storageProvider,httpProvider: widget.httpProvider)));},
                    child: Card(
                      key: Key('${user.userId}'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                key: (Key('image${user.userId}')),
                                  height:25,
                                  width:25,
                                  child:
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(10000.0),
                                      child: users[user] == null ?
                                      Icon(Icons.person)
                                          :
                                      CachedNetworkImage(
                                          key: ValueKey(index),
                                          imageUrl: users[user],
                                          useOldImageOnUrlChange: true,
                                          placeholder: (context, url) => Icon(Icons.person),
                                          errorWidget: (context, url, error) => Icon(Icons.person),
                                          fit: BoxFit.fill
                                      )
                                  )
                              ),
                              Padding(padding: EdgeInsets.only(left:5),child: Text(user.getName(),key:Key('username${user.userId}'))),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              FlatButton.icon(
                                key: (Key('chat${user.userId}')),
                                onPressed: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MessengerHandler(user: currentUser,peer: user)));
                                  //Navigator.of(context).push(MaterialPageRoute(builder: (context) => MessengerX( currentUser, user)));
                                },
                                icon: Icon(
                                    Icons.chat_bubble_outline, size: 30, color: Colors.black
                                ),
                                label: Text(
                                  '',
                                  style: TextStyle(color:Colors.white),
                                ),
                              ),

                              FlatButton.icon(
                                key: (Key('profileviewer${user.userId}')),
                                onPressed: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileViewer(otherUser: user, currentUser: widget.user,storageProvider: widget.storageProvider,httpProvider: widget.httpProvider)));
                                },
                                icon: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.black,
                                ),
                                label: Text(
                                  '',
                                  style: TextStyle(color:Colors.white),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

  Future <String> _getProfileImage(User user) async{
    final result = await widget.storageProvider.getOtherProfileImage(user);
    print(result);
    if(result != null){
      return result;
    }else{
      return null;
    }
  }


  void _getUser(String input) async {
    users.clear();

    dynamic result = await widget.httpProvider.getUsers(input);

    if (result != null) {
      List userData = json.decode(result);
      for(var element in userData){
        User user = User.fromJson(element);
        String image = await _getProfileImage(user);
        users[user] = image;
      }
    }

    String snackText = "";
    if (users.isEmpty) {
      snackText = "Hittade inga sökträffar";
    } else {
      snackText = "Hittade " + users.length.toString();
      if (users.length == 1) {
        snackText += " sökträff";
      } else {
        snackText += " sökträffar";
      }
    }

    if(this.mounted && context != null){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(snackText)));
      setState(() {_loading = false;});
    }
  }

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }
}