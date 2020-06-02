import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dog_prototype/loaders/CustomLoader.dart';
import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/pages/MessengerX.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image/network.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:dog_prototype/models/User.dart';

import 'profileViewer.dart';

class FindFriends extends StatefulWidget {

  final User user;
  FindFriends({this.user});

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

  //User ussr = new User()

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
                  User otherUser = users.keys.elementAt(index);

                  return GestureDetector(
                    onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileViewer(otherUser: otherUser)));},
                    child: Card(
                      color: Colors.brown[100],
                      key: ValueKey(index),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                  height:25,
                                  width:25,
                                  child:
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(10000.0),
                                      child: users[otherUser] == null ?
                                      Icon(Icons.person)
                                          :
                                      CachedNetworkImage(
                                          key: ValueKey(index),
                                          imageUrl: users[otherUser],
                                          useOldImageOnUrlChange: true,
                                          placeholder: (context, url) => Icon(Icons.person),
                                          errorWidget: (context, url, error) => Icon(Icons.person),
                                          fit: BoxFit.fill
                                      )
                                  )
                              ),
                              Padding(padding: EdgeInsets.only(left:5),child: Text(otherUser.getName())),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              FlatButton.icon(
                                onPressed: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MessengerX(user: currentUser, peer: otherUser)));
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
                                onPressed: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileViewer(otherUser: otherUser)));
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
    String token = await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token));
    try{
      final url = await http.get('https://dogsonfire.herokuapp.com/images/profiles/${user.userId}',
          headers:{'Authorization': 'Bearer $token'});
      
      if(url.statusCode==200){
        return url.body;
      }
      return null;
    }catch(e){
      print(e);
      return null;
    }
  }


  void _getUser(String input) async {
    users.clear();
    try{

      String token = await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token));

      final response = await http.get('https://dogsonfire.herokuapp.com/users?search=$input', headers: {
        'Authorization': 'Bearer $token',
      });


      if (response.statusCode == 200) {
        List userData = json.decode(response.body);
        print(response.body);
        for(var element in userData){
          User user = User.fromJson(element);
          String image = await _getProfileImage(user);
          users[user] = image;
        }
      } else {
        print('Failed to fetch username' + response.statusCode.toString());
        print(response.body);
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

      Scaffold.of(context).showSnackBar(SnackBar(content: Text(snackText)));

      setState(() {_loading = false;});
    }catch(e){

    }
  }
}
