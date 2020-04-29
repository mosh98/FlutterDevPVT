import 'package:dog_prototype/elements/bottomBar.dart';
import 'package:dog_prototype/elements/messageTile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  List<MessageTileData> tileList = [
    MessageTileData('placeholders/pernilla.jpg','Anders','H','15:12'),
    MessageTileData('placeholders/pernilla.jpg','Anderson','hundar asså'
        ' har du sett dom är typ en häst fast glad och varför är det så ens '
        'behövs dom typ eller vad tycker du asså undrar jag just nu'
        ' alltså förstår typ inte riktigt skulle vara sjysst om du kunde förklara','Igår'),
    MessageTileData('placeholders/pernilla.jpg','Andrea','Hej hej hej hej'
        ' hej hej hej hej hej hej hej hej hej','Torsdag'),
    MessageTileData('placeholders/pernilla.jpg','Andy','sup','Måndag')];
  

  
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
                child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) => Divider(),
                    itemCount: tileList.length
                    , itemBuilder: (context, index) {
                  return MessageTile('assets/pernilla.jpg',tileList[index].name,tileList[index].latestMessage,tileList[index].time);
                })
                ,
              ),
            ]));
  }
}
