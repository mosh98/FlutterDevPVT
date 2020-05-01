import 'package:flutter/material.dart';
import 'placeHolderHome.dart';
import 'signup.dart';

class LoginPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    //we customize our own build instead of the one inside Statelesswidget
    return new MaterialApp(
        home: new LoginP(),//home screen
        theme: new ThemeData( //colour
            primarySwatch: Colors.blue
        )
    );
  }
}

class LoginP extends StatefulWidget{
  //stateful since we want to add stateful widgets
  @override //=> lambda
  State createState() => new LoginPageState(); //creates new loginpagestate
}

class LoginPageState extends State<LoginP> with SingleTickerProviderStateMixin{

  AnimationController _iconAnimationController;
  Animation<double> _iconAnimation;

  @override
  void initState(){
    super.initState();
    _iconAnimationController = new AnimationController(
        vsync: this,
        duration: new Duration(milliseconds: 500)
    );
    _iconAnimation = new CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.easeOut
    );
    _iconAnimation.addListener(()=>this.setState((){}));
    _iconAnimationController.forward();
  }


  @override
  Widget build(BuildContext context){
    //scaffold is a structure
    return new Scaffold( //this is what is actually shown
      backgroundColor: Colors.white, //color
      body: new Stack(
        fit: StackFit.expand,
        children: <Widget>[

          new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Image(
                  image: new AssetImage('assets/loginpicture.jpg'),
                  height: 100.0,

                ),
                new Form(
                    child: new Theme(
                      data: new ThemeData(
                          brightness: Brightness.dark,
                          primarySwatch: Colors.teal,
                          inputDecorationTheme: new InputDecorationTheme(
                              labelStyle: new TextStyle(
                                  color: Colors.teal,
                                  fontSize: 20.0
                              )
                          )
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(40.0), //flyttar in texten så den inte är från början av skärmen till slutet
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new TextFormField(
                              decoration: new InputDecoration(
                                labelText: "Username* ",

                              ),
                              keyboardType: TextInputType.text,
                            ),
                            new TextFormField(
                              decoration: new InputDecoration(
                                labelText: "Password* ",
                              ),
                              keyboardType: TextInputType.text,
                              obscureText: true,
                            ),
                            new Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                            ),
                            new MaterialButton(
                              padding: const EdgeInsets.all(10.0),
                              height: 40.0,
                              minWidth: 100.0,
                              color: Colors.teal,
                              textColor: Colors.white,
                              child: new Text("Sign in"),
                              onPressed: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute<Null>(
                                        builder: (BuildContext context) {
                                          return new PlaceHolderApp();
                                        }));
                              },
                              splashColor: Colors.redAccent, //färgen när man trycker på knappen
                            ),
                            new Text(
                                "OR"
                            ),
                            new MaterialButton(
                              padding: const EdgeInsets.all(10.0),
                              height: 40.0,
                              minWidth: 100.0,
                              color: Colors.teal,
                              textColor: Colors.white,
                              child: new Text("Register new user"),
                              onPressed: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute<Null>(
                                        builder: (BuildContext context) {
                                          return new Signup();
                                        }));
                              },
                              splashColor: Colors.redAccent, //färgen när man trycker på knappen
                            ),
                            new Text(
                                "Forgot your password? Retrieve it here"
                            )
                          ],
                        ),
                      ),
                    )
                )
              ]
          )
        ],
      ),
    );
  }
}