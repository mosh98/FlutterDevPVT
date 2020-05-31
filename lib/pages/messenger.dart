import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class Messenger extends StatelessWidget {
  final databaseReference = Firestore.instance;
  final String recipient = "norp@florp.com";
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser user;

  void _onSendMessage(String content, String uid, String peerUid) {
    Firestore.instance
        .collection('users')
        .document(user.email)
        .collection('chats')
        .document(recipient)
        .collection('messages')
        .document()
        .setData({
      'from': recipient,
      'text': content,
      'timestamp': DateTime.now().toIso8601String().toString()
    });
    Firestore.instance
        .collection('users')
        .document(recipient)
        .collection('chats')
        .document(user.email)
        .collection('messages')
        .document()
        .setData({
      'from': user.email,
      'text': content,
      'timestamp': DateTime.now().toIso8601String().toString()
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class Message extends StatelessWidget {
  final String message;
  final String timeStamp;
  final String nameUser;
  final bool self = true;

  const Message({Key key, this.message, this.timeStamp, this.nameUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment:
            self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(nameUser),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(timeStamp),
              SizedBox(
                height: 8.0,
              ),
              Text(message)
            ],
          )
        ],
      ),
    );
  }
}
