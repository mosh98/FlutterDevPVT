import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:dog_prototype/models/User.dart';

class Search extends StatefulWidget {
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
                            Icon(Icons.portrait, size: 50, color: Colors.blue),
                            Text(users[index].getName()),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(Icons.chat_bubble, size: 40, color: Colors.blue),

                            Icon(Icons.keyboard_arrow_right, size: 40, color: Colors.black),

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
    final response = await http.get(
        'https://redesigned-backend.herokuapp.com/user/query?username=$input');
    if (response.statusCode == 200) {
      Map<String, dynamic> userData = json.decode(response.body);
      List userList = userData['content'];
      userList.forEach((element) => users.add(User.fromJson(element)));
    } else {
      print(
          'Failed to fetch username'); //todo: något annat ska ju hända egentligen
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
  }
}
