import 'dart:convert';

import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'mapPage.dart';
import 'package:http/http.dart' as http;

class StartPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[850],
        ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MaterialButton(
                  color: Colors.teal,
                  textColor: Colors.white,
                  height: 50.0,
                  minWidth: 150.0,
                  child: new Text("login"),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return new LoginPage();
                        }));
                  },
                ),
                Padding(child: Text("OR"), padding: EdgeInsets.all(10.0)),
                MaterialButton(
                  color: Colors.teal,
                  textColor: Colors.white,
                  height: 50.0,
                  minWidth: 150.0,
                  child: new Text("View map"),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                          return new MapPage();
                        }));
                  },
                ),
              ],
            )
        )
    );
  }
}
  
//  String _getFunFact(){ //TODO: FINISH METHOD
//    final response = http.get('https://some-random-api.ml/facts/dog');
//
//    if (response != null) {
//      Map f = jsonDecode(response.toString());
//    }
//    return "";
//  }
//}
//
//class RandomFact{
//  final String fact;
//
//  RandomFact(this.fact);
//
//  RandomFact.fromJson(Map<String,dynamic> json): fact = json['fact'];
//
//  Map<String,dynamic> toJson() => {'fact' : fact};
//}//https://flutter.dev/docs/development/data-and-backend/json