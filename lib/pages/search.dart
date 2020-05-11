import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';


class Search extends StatelessWidget{

  final textFieldController = TextEditingController();
  String change = '';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[850],
          centerTitle: true,
          title: Text('Search'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                decoration: InputDecoration(
                    hintText: "Search"
                ),
                keyboardType: TextInputType.text,
                controller: textFieldController,
                onSubmitted: (String input){
                  _getUser(input);
                },
              ),
            )
          ],
        )
    );
  }

  /**
   * Request the user that the user has searched for and decodes json to Flutter map.
   */
  void _getUser(String input) async {
    final response =
        await http.get('https://pvt-dogpark.herokuapp.com/user/find?name=$input');
    if(response.statusCode == 200){
      Map<String, dynamic> user = json.decode(response.body);
      print(user.toString());

    }else{
      print('Failed to fetch username'); //todo: något annat ska ju hända egentligen
    }
  }
}