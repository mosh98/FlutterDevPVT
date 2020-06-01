import 'dart:convert';

import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class DogDialog extends StatefulWidget{

  final BuildContext context;
  DogDialog(this.context);

  @override
  createState() => new _DialogState();
}

class _DialogState extends State<DogDialog>{

  String dogName = "";
  String breed = "";
  String dateOfBirth = "";
  double _kPickerSheetHeight = 75.0;
  double _kPickersheetWidth = 250.0;
  String gender = 'MALE'; //DEFAULT
  String neutered = 'Yes';

  DateTime _dateTime = DateTime.now();
  final f = new DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return _dogDialog();
  }

  Widget _dogDialog(){
    return SimpleDialog(
        contentPadding: EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))
        ),
        children: [
    Row(
    children: [
    Text('Information about your dog', style:TextStyle(fontSize: 20.0)),
    Padding(padding:EdgeInsets.only(left:15.0)),
    IconButton(icon: Icon(Icons.close), onPressed: (){Navigator.pop(context);})
    ],
    ),
    Form(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
    Padding(padding:EdgeInsets.only(top:20.0)),
    TextFormField(
    decoration: InputDecoration(
    hintText: 'Name*',
    border: new OutlineInputBorder(
    borderSide: new BorderSide(),
    borderRadius: new BorderRadius.circular(20.0)
    )
    ),
    onChanged: (String value){dogName = value;},
    ),
    Padding(padding: EdgeInsets.only(top:10.0)),
    TextFormField(
    decoration: InputDecoration(
    hintText: 'Breed*',
    border: new OutlineInputBorder(
    borderSide: new BorderSide(),
    borderRadius: new BorderRadius.circular(20.0)
    )
    ),
    onChanged: (String value){breed = value;},
    ),

    Padding(padding:EdgeInsets.only(top:10)),

    Container(
    decoration: BoxDecoration(
    borderRadius: new BorderRadius.circular(20.0),
    border: Border.all(color: Colors.black.withOpacity(0.4))
    ),
    child: ListTile(
    title: Align(
    alignment: Alignment.centerLeft,
    child: Text(
    'Gender:',
    textAlign: TextAlign.left,
    style: TextStyle(fontSize: 16)),
    ),
    trailing: DropdownButton<String>(
    value: gender,

    onChanged: (String newValue) {setState(() {
    setState(() {
    gender = newValue;
    });

    });},
    items: <String>[
    'MALE', 'FEMALE'
    ].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
    value:value,
    child:Text(value, style: TextStyle(fontSize: 15.0),),
    );
    }).toList(),
    ),
    ),
    ),

    Padding(padding:EdgeInsets.only(top:10)),

    if(gender == 'MALE')
    Container(
    decoration: BoxDecoration(
    borderRadius: new BorderRadius.circular(20.0),
    border: Border.all(color: Colors.black.withOpacity(0.4))
    ),
    child: ListTile(
    title: Text('Neutered:'),
    trailing: DropdownButton<String>(
    value: neutered,
    onChanged: (String newValue){setState(() {
    neutered = newValue;
    });},
    items: <String>[
    'Yes', 'No'
    ].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
    value:value,
    child:Text(value, style: TextStyle(fontSize: 16.0),),
    );
    }).toList(),
    )
    ),
    ),

    Padding(padding:EdgeInsets.only(top:10)),

    MaterialButton(
    minWidth: 375,
    height: 50,
    shape: new OutlineInputBorder(
    borderSide: new BorderSide(),
    borderRadius: new BorderRadius.circular(20.0))
    ,
    onPressed: () {
    showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) {
    return _buildBottomPicker(
    CupertinoDatePicker(
    mode: CupertinoDatePickerMode.date,
    maximumDate: DateTime.now(),
    minimumDate: DateTime(1900),
    initialDateTime: DateTime(1990),
    onDateTimeChanged: (DateTime newDateTime) {
    if (mounted) {
    setState(() => _dateTime = newDateTime

    );

    dateOfBirth = '${f.format(_dateTime)}';


    }
    },
    ),
    );
    },
    );
    },
    child:
    Align(
    alignment: Alignment.centerLeft,
    key:Key('date_of_birth'),
    child:

    Text('Date of Birth ${f.format(_dateTime)}',
    textAlign: TextAlign.left,
    style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: Colors.black.withOpacity(0.4)))
    )),

    Padding(padding:EdgeInsets.only(top:25)),

    SizedBox(
    width: double.infinity,
    child: RaisedButton(
    onPressed: ()async{
    await _addDog();
    Navigator.of(context).pop();
    },
    child: Text('Add dog'),
    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
    ),
    ),
    ],
    )
    )
    ],
    );
  }

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: _kPickerSheetHeight,
      width: _kPickersheetWidth,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  _addDog() async{
    String snackText = "";
    bool neut = false;
    if(dateOfBirth.isEmpty){
      dateOfBirth = f.format(_dateTime);
    }

    if(dogName.isEmpty || breed.isEmpty || gender.isEmpty){
      print('wrong inputs');
      snackText = "Please specify name and breed.";

      Scaffold.of(widget.context).showSnackBar(SnackBar(content: Text(snackText)));
      return;
    }

    if(gender == 'FEMALE')
      neutered = null;

    if(neutered != null){
      if(neutered == 'Yes'){
        neut = true;
      }else{
        neut = false;
      }
    }

    try{
      String token = await AuthService().getCurrentFirebaseUser().then((firebaseUser) => firebaseUser.getIdToken().then((tokenResult) => tokenResult.token));

      final http.Response response = await http.post(
          'https://dogsonfire.herokuapp.com/dogs',
          headers:{
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String,String>{
            'name':dogName,
            'breed':breed,
            'dateOfBirth':dateOfBirth,
            'gender':gender,
            'neutered':neut.toString(),
            'description':null,
          })
      );

      if(response.statusCode==201){
        print(response.statusCode);
        snackText = "$dogName was added to your profile!";
      }else{
        print(response.statusCode);
        print(response.body);
        snackText = "Failed to upload $dogName to your profile.";
      }
    }catch(e){
      print(e);
      snackText = "Failed to upload $dogName to your profile.";
    }
    Scaffold.of(widget.context).showSnackBar(SnackBar(content: Text(snackText)));
  }
}