import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

class Messenger extends StatelessWidget {

  final databaseReference = Firestore.instance;
  final String recipient = "norp@florp.com";
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser user;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future<Map<String, dynamic>> sendAndRetrieveMessage(String body, String title) async {
    await _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );

    String teken = 'dSlNvWn9-FQ:APA91bHU3vCNpLz6tHMW8GSFJzqGDl_2B2j7uoDYeMSjMg_ac9lmdtDCKIFiElTUZDezNUvBCHm0wOA4nf-23ADkbTUvmJJvN02eRBCMMec9DMqhXH8K9qrJJff609c9Rnu6GNOP3XMe';

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAApxhRlHQ:APA91bHl1eBjWN0jTAwguFZKAWPES8DnTa5A7Akw-DSrQiG4mE2lDo-12kzWLke1Kj1rAZ00yguG9FOsLZCODNHLq1-wZOLa_Ny1hKBz-7pRt3mgc8F4FgYk5nykcX7yBstZIQ4-8uuk',
        //authrization is the firebase CloudStore server key
      },

      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '$body',
            'title': '$title'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': teken,
        },
      ),
    );
  }

  void _onSendMessage(String content, String uid, String peerUid) {

    String senderToken;
    _firebaseMessaging.getToken().then((value) => senderToken = value);

    //This user
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
      'timestamp': DateTime.now().toIso8601String().toString(),
      'senderToken': senderToken
    });

    //The other user or the recipient
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
