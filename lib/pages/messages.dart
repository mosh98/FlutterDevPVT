import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'MessengerHandler.dart';

class Messages extends StatelessWidget {
  User user;
  ScrollController scrollController = ScrollController();
  StorageProvider storageProvider;

  Messages({@required this.user, this.storageProvider});

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
                            .map((doc) => PeerTile(user, doc, storageProvider))
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

class PeerTile extends StatefulWidget {
  String profileImage;
  User user;
  User peer;
  DocumentSnapshot doc;
  StorageProvider storageProvider;

  PeerTile(User user, DocumentSnapshot doc, StorageProvider storageProvider) {
    this.user = user;
    this.doc = doc;
    this.storageProvider = storageProvider;
  }

  @override
  State<StatefulWidget> createState() => PeerTileState();
}

class PeerTileState extends State<PeerTile> {
  String profileImage;
  bool loadingImage = true;
  bool loadingUser = true;

  @override
  void initState() {
    _getProfileImage();
    super.initState();
  }

  Future<User> _getUser(String uid) async {
    try {
      String token = await AuthService()
          .getCurrentFirebaseUser()
          .then((value) => value.getIdToken().then((value) => value.token));
      final response = await http
          .get('https://dogsonfire.herokuapp.com/users?uid=$uid', headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        setState(() {
          widget.peer = User.fromJson(json.decode(response.body));
          loadingUser = false;
          print(User.fromJson(json.decode(response.body)));
        });
      } else {
        print('Failed to fetch user' + response.statusCode.toString());
        print(response.body);
      }
    } catch (e) {}
  }

  Future<String> _getProfileImage() async {
    await _getUser(widget.doc.data['uid']);
    final result =
        await widget.storageProvider.getOtherProfileImage(widget.peer);
    setState(() {
      profileImage = result;
      loadingImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: loadingImage
          ? CircleAvatar(
        child: Icon(Icons.person, color: Colors.grey[800],),
        radius: 30,
        backgroundColor: Colors.white70,
      )
          : CircleAvatar(
        radius: 30,
        backgroundColor: Colors.white70,
        child: CachedNetworkImage(
            imageUrl: profileImage,
            placeholder: (context, url) => DefaultLoader(),
            errorWidget: (context, url, error) => CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
                backgroundColor: Colors.grey))),

      title:
          loadingUser ? Text('Loading...') : Text(widget.doc.data['username']),
      subtitle: loadingUser ? Text('') : Text(widget.doc.data['latestMessage']),
      onTap: () async {
        if (!loadingUser) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  MessengerHandler(user: widget.user, peer: widget.peer)));
        }
      },
    );
  }
}
