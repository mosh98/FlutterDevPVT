import 'dart:convert';

import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'RegisterPage.dart';
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

  String fact;

  @override
  void initState() {
    super.initState();
    _getFunFact();
  }

  @override
  Widget build(BuildContext context) {


    if(fact == null){
      return DefaultLoader();
    }else{
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
  }

  Widget _factSection(){
    return Container(
      child: Column(
        children: <Widget>[
          Text(
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
              key: Key('login'),
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
                key: Key('viewmap'),
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

            Padding(
              padding: EdgeInsets.only(top:15),
              child: GestureDetector(
                key: Key('register'),
                child: Text(
                  "Don't have an account? Register here."
                ),
                onTap: (){ Navigator.of(context).push(
                    MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return new RegisterPage();
                        }));},
              ),
            )
          ],
        )
    );
  }

  void _getFunFact() async{
    final response = await http.get('https://some-random-api.ml/facts/dog');
    if(response.statusCode == 200){
      Map<String,dynamic> f = json.decode(response.body);
      setState(() {
        fact = f['fact'];
      });
    }else{
      setState(() {
        fact = 'It seems like there are no random facts about dogs in this particular moment.';
      });
    }
  }
}