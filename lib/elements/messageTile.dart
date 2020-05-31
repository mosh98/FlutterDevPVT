import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  String profileImage;
  String name;
  String latestMessage;
  String time;

  MessageTile(
      String profileImage, String name, String latestMessage, String time) {
    this.profileImage = profileImage;
    this.name = name;
    this.latestMessage = latestMessage;
    this.time = time;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){ //Navigator.push(context, MaterialPageRoute(builder: (context) => NewMessage()));
     },
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.red[700],
          child: CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(profileImage)),
        ),
        title: Text(name),
        subtitle: Text(
          latestMessage,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(time));
  }
}

class MessageTileData {
  MessageTileData(
      String profileImage, String name, String latestMessage, String time) {
    this.profileImage = profileImage;
    this.name = name;
    this.latestMessage = latestMessage;
    this.time = time;
  }

  String profileImage;
  String name;
  String latestMessage;
  String time;
}
