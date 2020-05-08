import 'dart:convert';

import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'mapPage.dart';
import 'package:http/http.dart' as http;

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: StatefulStartPage(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
        )
    );
  }
}

class StatefulStartPage extends StatefulWidget{
  @override
  State createState() => new StartPageState();
}

class StartPageState extends State<StatefulStartPage>{

  String fact = "";

  @override
  void initState() {
    super.initState();
    _getFunFact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          padding: const EdgeInsets.fromLTRB(10, 250, 10, 0),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _factSection(),
                _buttonSection(),
              ],
            )
          ],
        )
    );
  }

  Widget _factSection(){
    return Container(
      child: Column(
        children: <Widget>[
          Text( //TODO: TOO MANY REQUESTS BUG?
            fact.toLowerCase(),
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height:10),
          Text('Anyways..'),
        ],
      ),
    );
  }

  Widget _buttonSection(){
    return Container(
        padding: EdgeInsets.only(top:15),
        child: Column(
          children: <Widget>[
            MaterialButton(
              height: 40.0,
              minWidth: 250.0,
              color: Colors.black54,
              textColor: Colors.white,
              child: new Text("Login"),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return new LoginPage();
                    }));
              },
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            ),
            Text('OR'),
            MaterialButton(
                height: 40.0,
                minWidth: 250.0,
                color: Colors.black54,
                textColor: Colors.white,
                child: new Text("View map"),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext context) {
                        return new MapPage();
                      }));
                },
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
            ),
          ],
        )
    );
  }

  void _getFunFact() async{
    final response = await http.get('https://some-random-api.ml/facts/dog');
    if(response.statusCode == 200){
      Map<String,dynamic> f = json.decode(response.body);
      fact = f['fact'];
    }
  }
}