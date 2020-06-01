import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

class MessengerX extends StatelessWidget {
  User user;
  User peer;

  MessengerX({User user, User peer});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MessengerHandler(user: user, peer: peer);
  }
}

class MessengerHandler extends StatefulWidget{
  User user;
  User peer;


  MessengerHandler({User peer, User user});

  @override
  _Messenger createState() => _Messenger(user: user,peer: peer);

//
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//     new Messenger(user: user,peer: peer);
//  }


}

class _Messenger extends State<MessengerHandler> {

  final databaseReference = Firestore.instance;

  FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  User peer;
  String recipientToken;
  //String recipientUsername;

  final textController = TextEditingController();
  ScrollController scrollController = ScrollController();


  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//  _Messenger(User user, User peer);

  _Messenger( {this.user,this.peer});


  @override
  void initState() {

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );


  }

  Future<TokenFcmJson> retireveRecipientToken(String username) async{
    //get https://fcm-token.herokuapp.com/user/getFcmByUsername?username=username

    String link = 'https://fcm-token.herokuapp.com/user/getFcmByUsername?username='+ username;
    final response = await http.get(link);

    if(response.statusCode == 200){
      return TokenFcmJson.fromJson(json.decode(response.body));
    }else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load User');
    }

  }
  //final String recipient = peer.userId;//TODO: This is going to be the UID or username

  Future<Map<String, dynamic>> sendAndRetrieveMessage(String body, String title) async {
    await _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );

    if(recipientToken.isEmpty){
         Future<TokenFcmJson> jayZ = retireveRecipientToken(peer.username);

      // update recipient token.
       jayZ.then((value) => recipientToken = value.fcmToken);
    }

    //String recipientToken = 'dSlNvWn9-FQ:APA91bHU3vCNpLz6tHMW8GSFJzqGDl_2B2j7uoDYeMSjMg_ac9lmdtDCKIFiElTUZDezNUvBCHm0wOA4nf-23ADkbTUvmJJvN02eRBCMMec9DMqhXH8K9qrJJff609c9Rnu6GNOP3XMe';

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
          'to': recipientToken,
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
        .document(user.userId)
        .collection('chats')
        .document(peer.userId)
        .collection('messages')
        .document()
        .setData({
      'from': peer.username,
      'text': content,
      'timestamp': DateTime.now().toIso8601String().toString(),
      'senderToken': senderToken
    });

    //The other user or the recipient
    Firestore.instance
        .collection('users')
        .document(peer.userId)
        .collection('chats')
        .document(user.userId)
        .collection('messages')
        .document()
        .setData({
      'from': user.username,
      'text': content,
      'timestamp': DateTime.now().toIso8601String().toString(),
      'senderToken': senderToken
    });

    String nameOfSender; //This will be the name of this user
    sendAndRetrieveMessage(content, nameOfSender);
  }




  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: true,
        child: Scaffold(
          //resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text('Chat window'),
          ),
          body: SafeArea(

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 10,
                  child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('users').document(user.userId).collection('chats').document(peer.userId).collection('messages').orderBy('timestamp')
                       // .collection('users').document('florp@norp.com').collection('chats').document(recipient).collection('messages').orderBy('timestamp')
                        .snapshots(),

                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Text('Data is coming');

                      List<DocumentSnapshot> docs = snapshot.data.documents;
                      //get the recipient token
                      //recipientToken = docs.elementAt(docs.length).,

                      docs.map((e) => recipientToken = e.data['senderToken']);

                      List<Widget> messages = docs.map((doc) =>


                          Message(
                            message: doc.data['text'],
                            timeStamp: doc.data['timestamp'],
                            nameUser: doc.data['from'],
                            token: doc.data['senderToken'],
                          ),
                      ).toList();

                      return ListView(

                        controller: scrollController,
                        children: <Widget>[
                          ...messages,
                        ],
                      );

                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                        hintText: "Skicka ett meddelande",
                        suffixIcon: IconButton(
                          onPressed: () {
                            _onSendMessage(textController.text, "b2YxBTdWCTTbxSb6lSvJyskuyN22","ZPdRVUxgUzeMozR6Z6WAhqV13ZZ2");
                            textController.clear();
                            scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.blue,
                          ),

                          //color: Colors.blue,
                        )),
                  ),
                )
              ],
            ),
          ),
        ));
  }


//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    throw UnimplementedError();
//  }
}

class Message extends StatelessWidget {

  final String message;
  final String timeStamp;
  final String nameUser;
  final String token;
  final bool self = true;

  const Message({Key key, this.message, this.timeStamp, this.nameUser, this.token})
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

class TokenFcmJson {

  int id;
  String username;
  String email;
  String fcmToken;


  TokenFcmJson({this.id, this.username, this.email, this.fcmToken});

  factory TokenFcmJson.fromJson(Map<String, dynamic> json) => TokenFcmJson(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fcmToken: json['fcmToken']
    );

}

//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    throw UnimplementedError();
//  }
