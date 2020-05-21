import 'package:flutter/cupertino.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class Messenger extends StatelessWidget{
  StompClient client = StompClient(
      config: StompConfig(
          url: 'wss://yourserver',
          onConnect: onConnectCallback
      )
  );

  static void onConnectCallback(StompClient client, StompFrame connectFrame) {
    // use the client object passed.
  }

  Messenger() {
    client.activate();

}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}