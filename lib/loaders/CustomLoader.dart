
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoader extends StatefulWidget {

  final Text textWidget;
  final Padding padding;
  CustomLoader({this.textWidget, this.padding});

  @override
  _CustomLoaderState createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader> {

  bool hasTextWidget = false;

  @override
  void initState() {
    if(widget.textWidget != null)
      hasTextWidget = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.brown[100],
          child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                SpinKitChasingDots(
                color: Colors.brown,
                size: 50.0,
              ),
              if(widget.padding != null)
                widget.padding,

          if(hasTextWidget)
            widget.textWidget
      ],
    )
    ),
    ),
    );
  }
}
