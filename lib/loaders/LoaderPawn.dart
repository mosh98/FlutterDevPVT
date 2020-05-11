//TODO NOT FINISHED
import 'package:flutter/widgets.dart';

class LoaderPawn extends StatefulWidget{
  @override
  _LoaderPawnState createState() => _LoaderPawnState();
}

class _LoaderPawnState extends State<LoaderPawn> with TickerProviderStateMixin{

  Animation<double> _animation1;
  AnimationController _controller1, _controller2;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(vsync:this, duration: Duration(milliseconds: 2200));

    _controller2 = AnimationController(vsync:this, duration: Duration(milliseconds: 2000));

    _animation1 = new Tween(begin: 0.5, end:1.0).animate(new CurvedAnimation(parent: _controller2, curve: Curves.easeInOut),);

    _controller1.repeat();

    _controller2.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Opacity(
            opacity: _animation1.value,
            child: Image.asset('assets/pawn.jpg',fit:BoxFit.cover),
          ),
        Container(
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
          Positioned(
              bottom: 260.0,
              right: 180.0,
              child:ScaleTransition(
                  scale: _controller1,
                  child:Container(
                    width: 100,
                    height: 100,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(
                              'assets/pawn.jpg'
                          ),
                        )
                    ),
                  )
              )
          ),
          Text("Loading.."),
        ],
      ),
      ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }
}