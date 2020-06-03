import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_badger/flutter_app_badger.dart';

import 'dart:async';
import 'dart:convert';

class MessengerHandler extends StatefulWidget {
  User user;
  User peer;


  MessengerHandler({ this.user,this.peer,});


  @override
  _Messenger createState() => _Messenger(user: this.user, peer: this.peer);
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

  _Messenger({this.user,this.peer});



  void configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

//  Future _showNotifications(FlutterLocalNotificationsPlugin notifications,{
//    String title,
//    String body,
//    NotificationDetails type,
//    int id = 0
//  }) => notifications.show(id, title, body, type);

  void showNotification(message) async{

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        'your channel description',
        importance: Importance.Max,
        priority: Priority.High,
        enableVibration: true
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, message['title'].toString(), message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  @override
  void initState() {

    configLocalNotification();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        showNotification(message);
        //print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        showNotification(message);
        //print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
         showNotification(message);
       // print("onResume: $message");
      },
    );




  }



  Future<TokenFcmJson> retireveRecipientToken(String username) async{
    //get https://fcm-token.herokuapp.com/user/getFcmByUsername?username=username

    String link = 'https://fcm-token.herokuapp.com/user/getFcmByUsername?username='+ username;
    final response = await http.get(link);

    if(response.statusCode == 200){
      return  TokenFcmJson.fromJson(json.decode(response.body));
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


         Future<TokenFcmJson> jayZ =  retireveRecipientToken(peer.username);

      // update recipient token.
       await jayZ.then((value) => recipientToken = value.fcmToken);
        print(recipientToken);

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAfhwE_ps:APA91bGAiaPQ__s8EAcSqyX2oM4kAGsxuE3WXTm_FFQiHE6BbeIcKs2SGQwR4jOr6gCN9CCHwjRoFkcVuEj5aTEGPdllAKxQOfyb5AdQX7OV1TUGFEfxr-FHAgtcUqSuSpMDtEmuS6AX',
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

  void _onSendMessage(String content) {
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
      'from': user.username,
      'text': content,
      'timestamp': DateTime.now().toIso8601String().toString(),
      //'senderToken': senderToken
    });

    Firestore.instance
        .collection('users')
        .document(user.userId)
        .collection('chats')
        .document(peer.userId)
        .setData({
      'latestMessage': content,
      'timestamp': DateTime.now().toIso8601String().toString(),
      'username':peer.username,
      'uid': peer.userId,
      //'senderToken': senderToken
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
      'timestamp': DateTime.now().toIso8601String().toString()
    });

    Firestore.instance
        .collection('users')
        .document(peer.userId)
        .collection('chats')
        .document(user.userId)
        .setData({
      'latestMessage': content,
      'timestamp': DateTime.now().toIso8601String().toString(),
      'username':user.username,
      'uid': user.userId,
    });

    String nameOfSender = peer.getName(); //This will be the name of this user
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
                        .collection('users')
                        .document(user.userId)
                        .collection('chats')
                        .document(peer.userId)
                        .collection('messages')
                        .orderBy('timestamp')
                        // .collection('users').document('florp@norp.com').collection('chats').document(recipient).collection('messages').orderBy('timestamp')
                        .snapshots(),

                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Text('Data is coming');

                      List<DocumentSnapshot> docs = snapshot.data.documents;
                      //get the recipient token
                      //recipientToken = docs.elementAt(docs.length).,

                      // docs.map((e) => recipientToken = e.data['senderToken']);

                      List<Widget> messages = docs
                          .map(
                            (doc) => Message(
                              message: doc.data['text'],
                              timeStamp: doc.data['timestamp'],
                              nameUser: doc.data['from'],
                              token: doc.data['senderToken'],
                            ),
                          )
                          .toList();

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
                            _onSendMessage(
                                textController.text,);
                            textController.clear();
                            scrollController.animateTo(
                                scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.easeOut);
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

  const Message(
      {Key key, this.message, this.timeStamp, this.nameUser, this.token})
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
