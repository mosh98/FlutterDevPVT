import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DefaultLoader extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
            child: SpinKitChasingDots(
              color: Colors.brown,
              size: 50.0,
            )
        )
    );
  }
}