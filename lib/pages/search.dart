import 'dart:convert';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:dog_prototype/models/User.dart';

import 'profileViewer.dart';

class Search extends StatefulWidget {

  final User user;
  Search({this.user});

  @override
  SearchState createState() => SearchState();
}

class SearchState extends State<Search> {


  List<User> users = new List<User>();

  final textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        centerTitle: true,
        title: Text('Search'),
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
                  _getUser(input);
                }),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(Icons.portrait, size: 50, color: Colors.black),
                            Text(users[index].getName()),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(Icons.chat_bubble_outline, size: 30, color: Colors.black),

                            FlatButton.icon(
                            onPressed: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileViewer(otherUser: users[index])));
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
                  );
                }
            ),
          ),
        ],
      ),
    );
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
        userData.forEach((element) {users.add(User.fromJson(element));});
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

      setState(() {});
    }catch(e){

    }
  }
}
