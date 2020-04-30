import 'package:flutter/material.dart';

//TODO: kladdig klass, ska städa lite
class Search extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    textFieldController.addListener(_printLatestValue);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        centerTitle: true,
        title: Text('Search'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Search"
              ),
              keyboardType: TextInputType.text,
              controller: textFieldController,
            ),
          )
        ],
      )
    );
  }


  //TODO
  /**
   * Borde denna metod egentligen ligga i main?
   *
   *  @override
      void dispose(){
      textFieldController.dispose();
      print("testing, disposed.");
      }
   *
   * https://flutter.dev/docs/cookbook/forms/retrieve-input
   */
  final textFieldController = TextEditingController();

  _printLatestValue(){
    print("testing: ${textFieldController.text}");
  }
}

