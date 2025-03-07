import 'package:dog_prototype/pages/MessengerHandler.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  String profileImage;
  String name;
  String latestMessage;
  String time;

  MessageTile({
      String profileImage, String name, String latestMessage, String time});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => MessengerHandler() ));
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
