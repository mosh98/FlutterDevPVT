import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_prototype/elements/bottomBar.dart';
import 'package:dog_prototype/elements/messageTile.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'MessengerHandler.dart';


class Messages extends StatelessWidget {
  User user;
  ScrollController scrollController;

  Messages({this.user});

  Future<User> getUser(String uid) async {
    try{
      String token = await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token));

      final response = await http.get('https://dogsonfire.herokuapp.com/users?uid=$uid', headers: {
        'Authorization': 'Bearer $token',
      });


      if (response.statusCode == 200) {
        print(User.fromJson(json.decode(response.body)));
        return User.fromJson(json.decode(response.body));

        }
      else {
        print('Failed to fetch user' + response.statusCode.toString());
        print(response.body);
      }
      } catch(e){

    }



    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[850],
          centerTitle: true,
          title: Text('Messages'),
          actions: <Widget>[Icon(Icons.add)],
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                  flex: 3,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Icon(Icons.search),
                        ),
                        Flexible(
                          flex: 10,
                          child: TextField(),
                        )
                      ],
                    ),
                  )),
              Expanded(
                  flex: 20,
                  child: StreamBuilder(
                      stream: Firestore.instance
                          .collection('users')
                          .document(user.userId)
                          .collection('chats')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Text('loading new message');
                        List<DocumentSnapshot> docs = snapshot.data.documents;

                        List<Widget> messages = docs
                            .map(
                              (doc) => ListTile(
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.red[700],
                                    child: CircleAvatar(
                                        radius: 25,
                                        backgroundImage: AssetImage('assets/pernilla.jpg')),
                                  ),
                                title: Text(doc.data['username']),
                                subtitle: Text(doc.data['latestMessage']),
                                onTap:() async {
                                    User peer = await getUser(doc.data['uid']);
                                    print(peer);

                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                        MessengerHandler(user: user,peer: peer)));
                                },
                              )
                            )
                            .toList();

                        return ListView(
                            controller: scrollController,
                            children: <Widget>[
                              ...messages,
                            ]);
                      })),
            ]));
  }
}
