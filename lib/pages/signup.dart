import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Sign up';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
          backgroundColor: Colors.grey[850],
          centerTitle: true
        ),
        body: MyCustomForm(),
      ),
    );
  }
}


class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
 
    return Form(
      key: _formKey,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

        Padding(    
        padding: const EdgeInsets.only(left:20, right: 20, top: 20),
        child:
        MaterialButton(
        minWidth: 375,
        height: 50,
        shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey[850])),
        onPressed: () {},
        color: Colors.grey[850],
        textColor: Colors.white,
        child: Text('Sign up with FaceBook',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, fontFamily: 'RobotoMono'))
    )
        ),

          Padding(
            padding: const EdgeInsets.only(left: 160.0, top: 20.0),
            child: 
            Text(
            'or with email',
            style: TextStyle(fontFamily: 'RobotoMono', color: Colors.black.withOpacity(0.3)),
            textAlign: TextAlign.center
          )
      ),
          Padding(
            padding: const EdgeInsets.only(left:20, right: 20, top: 20),
            child:
          TextFormField(
          decoration: new InputDecoration(
          labelText: 'Email*',
          border: new OutlineInputBorder(
            borderSide: new BorderSide()
          )
          ),
          keyboardType: TextInputType.text,                 
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a valid mailadress';
              }
              return null;
            },
          ),
          ),

          Padding(
            padding: const EdgeInsets.only(left:20, right: 20, top: 10),
            child:
          TextFormField(
          decoration: new InputDecoration(
          labelText: 'Choose password*',
          border: new OutlineInputBorder(
            borderSide: new BorderSide()
          )
          ),
          keyboardType: TextInputType.text,                 
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a valid password';
              }
              return null;
            },
          ),
          ),

         Padding(
            padding: const EdgeInsets.only(left:20, right: 20, top: 10),
            child:
          TextFormField(
          decoration: new InputDecoration(
          labelText: 'Choose username*',
          border: new OutlineInputBorder(
            borderSide: new BorderSide()
          )
          ),
          keyboardType: TextInputType.text,                 
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a valid username';
              }
              return null;
            },
          ),
          ),

         Padding(
            padding: const EdgeInsets.only(left:20, right: 20, top: 10),
            child:
          TextFormField(
          decoration: new InputDecoration(
          labelText: 'Date of birth*',
          border: new OutlineInputBorder(
            borderSide: new BorderSide()
          )
          ),
          keyboardType: TextInputType.text,                 
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a valid date';
              }
              return null;
            },
          ),
          ),

         Padding(
            padding: const EdgeInsets.only(left:20, right: 20, top: 10),
            child:
          TextFormField(
          decoration: new InputDecoration(
          labelText: 'Gender*',
          border: new OutlineInputBorder(
            borderSide: new BorderSide()
          )
          ),
          keyboardType: TextInputType.text,                 
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter something';
              }
              return null;
            },
          ),
          ),
        
          Padding(
            padding: const EdgeInsets.only(left: 75, right: 20, top: 10),
            child: 
            Text(
            'By proceeding you also agree \n to the Terms of Service and Privacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'RobotoMono', color: Colors.black.withOpacity(0.3)),
          )
      ),

             Padding(    
        padding: const EdgeInsets.only(left:20, right: 20, top: 20),
        child:
        MaterialButton(
        minWidth: 375,
        height: 50,
        shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey[850])),
        onPressed: () {
          // Validate returns true if the form is valid, or false
                // otherwise.
                if (_formKey.currentState.validate()) {
                  // If the form is valid, display a Snackbar.
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                }
        },
        color: Colors.white,
        textColor: Colors.black,
        child: Text('Sign up',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: Colors.black.withOpacity(0.6)))
      )
    ),
  ],
  ),
  );
  }
}