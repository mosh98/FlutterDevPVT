import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'mapPage.dart';

class StartPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       backgroundColor: Colors.grey[850],
     ),
      body: Container(
        padding: const EdgeInsets.all(40.0),
        child:Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              MaterialButton(
                  padding: const EdgeInsets.all(20.0),
                  height: 40.0,
                  minWidth: 100.0,
                  color: Colors.black54,
                  child: new Text("login"),
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute<Null>(builder: (BuildContext context){
                      return new LoginPage();
                    }));
                  },
              ),
              Text(
                "OR",
              ),
              MaterialButton(
                  padding: const EdgeInsets.all(20.0),
                  height: 40.0,
                  minWidth: 100.0,
                  color: Colors.black54,
                  child: new Text("View map"),
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                    return new MapPage();
                  }));
                },
              ),
            ],
          )
        )
      )
   );
  }


}