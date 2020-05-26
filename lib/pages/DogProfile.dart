import 'dart:convert';
import 'dart:io';

import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DogProfile extends StatefulWidget {

  final Dog dog;
  DogProfile({this.dog});

  @override
  _DogProfileState createState() => _DogProfileState();
}

class _DogProfileState extends State<DogProfile> {

  ProfileState _state = ProfileState.About;
  File _image;
  Dog dog;

  @override
  void initState() {
    if(dog == null){
      dog = widget.dog;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Dog Profile'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(15.0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pictureSection(),
              _informationSection(),
            ],
        )
      ),
    );
  }

  Widget _pictureSection(){
    //TODO, WHEN PICTURES IS FINISHED
    return Expanded(
      flex: 2,
      child: Center(
        child: Column(
            children: [
              GestureDetector(
                  onTap: getImage,
                  child: _image == null
                      ? CircleAvatar(radius: 40, child: Icon(Icons.add_a_photo, color: Colors.white), backgroundColor:Colors.grey)
                      : CircleAvatar(radius: 40, backgroundImage: FileImage(_image))
              ),
              _stateSection()
            ],
        ),
      )
    );
  }

  Widget _stateSection(){
    return DefaultTabController(
        length: 2,
        child: TabBar(
            labelColor: Colors.black,
            onTap: (value){
              if(value==0){
                setState(() {
                  _state = ProfileState.About;
                });
              }else{
                setState(() {
                  _state = ProfileState.Awards;
                });
              }
            },
            indicatorWeight: 0.1,
            unselectedLabelColor: Colors.grey,
            tabs: <Widget>[
              Tab(
                  icon: Icon(Icons.person),
                  child:Text('About')
              ),
              Tab(
                  icon: Icon(Icons.star),
                  child:Text('Awards')
              )
            ]
        )
    );
  }

  Widget _informationSection() {
    return Expanded(
     flex: 4,
     child: Column(
       children: [
         Expanded(
           flex: 7,
           child: _state == ProfileState.About ?
           aboutSection()
               :
           awardsSection(),
         ),
         Expanded(
           flex: 3,
             child: _descriptionSection()
         ),
       ],
     )
    );
  }

  Widget aboutSection(){
    return ListView(
      children: ListTile.divideTiles(
        context: context,
          tiles: [
            ListTile(
                title: Text('Name:'),
                trailing: Text(widget.dog.name ?? 'No name specified.'),
                onTap: (){_setName();},
            ),
            ListTile(
                title: Text('Breed:'),
                trailing: Text(widget.dog.breed ?? 'No breed specified.'),
                onTap: (){_setBreed();},
            ),
            ListTile(
                title: Text('Date of birth:'),
                trailing: Text(widget.dog.dateOfBirth ?? 'No date of birth specified.'),
                onTap: (){_setDateOfBirth();},
            ),
            ListTile(
                title: Text('Neutered:'),
                trailing: DropdownButton<String>(
                  value: widget.dog.getNeutered(),
                  onChanged: (String newValue){_updateNeutered(newValue);},
                  items: <String>[
                    'Yes', 'No'
                  ].map<DropdownMenuItem<String>>((String value){
                    return DropdownMenuItem<String>(
                      value:value,
                      child:Text(value, style: TextStyle(fontSize: 15.0),),
                    );
                  }).toList(),
                )
            ),
            ListTile(
                title: Text('Gender:'),
                trailing: DropdownButton<String>(
                  value: widget.dog.gender ?? 'MALE',
                  onChanged: (String newValue){_updateGender(newValue);},
                  items: <String>[
                    'MALE', 'FEMALE'
                  ].map<DropdownMenuItem<String>>((String value){
                    return DropdownMenuItem<String>(
                      value:value,
                      child:Text(value, style: TextStyle(fontSize: 15.0),),
                    );
                  }).toList(),
                )
            ),
          ]
      ).toList(),
    );
  }

  Widget awardsSection(){
    return Column(
      children: [
        Text('IF WE HAVE TIME TO IMPLEMENT THIS')
      ],
    );
  }

  Widget _descriptionSection(){
    return ListView(
      children: [
        ListTile(
          title: Text('Description', style: TextStyle(fontSize: 20)),
          trailing: IconButton(icon:Icon(Icons.edit), onPressed: (){_editDescription();}),
        ),
        Text(widget.dog.description ?? 'Add a description to your dog!'),
      ],
    );
  }

  _editDescription() async{

    String desc = "";

    await showDialog(
        context: context,
        builder: (BuildContext context){
      return SizedBox(
        height: 400.0,
        child: Dialog(
          child: Row(
            children: [
              Padding(padding:EdgeInsets.only(right:10.0)),
              Expanded(
                child:TextFormField(
                  decoration: InputDecoration(
                      hintText: 'Enter a new name'
                  ),
                  onChanged: (String newValue){desc = newValue;},
                ),
              ),
              IconButton(icon: Icon(Icons.done),
                  onPressed: () async{

                    Navigator.pop(context);
                  }),
              IconButton(icon: Icon(Icons.close), onPressed: (){Navigator.pop(context);})
            ],
          ),
        ),
      );
    }
    );
  }

  Future getImage() async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  void _setName() async{

    String name = "";

    await showDialog(
        context: context,
        builder: (BuildContext context){
          return Dialog(
            child: Row(
              children: [
                Padding(padding:EdgeInsets.only(right:10.0)),
                Expanded(
                  child:TextFormField(
                  decoration: InputDecoration(
                      hintText: 'Enter a new name'
                      ),
                    onChanged: (String newValue){name = newValue;},
                  ),
                ),
                IconButton(icon: Icon(Icons.done),
                    onPressed: () async{
                  await _updateName(name);
                  Navigator.pop(context);
                }),
                IconButton(icon: Icon(Icons.close), onPressed: (){Navigator.pop(context);})
              ],
            ),
          );
      }
    );
  }

  _updateName(String name) async{
    try{
      final http.Response response = await http.put( //register to database
          'https://dogsonfire.herokuapp.com/dogs',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token))}'
          },
          body: jsonEncode(<String,String>{
            "name": name,
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print("Updated name, response code: " + response.statusCode.toString());
        setState(() {widget.dog.setName(name);});
      }else{ //Something went wrong
        print("Something went wrong with updating name: " + response.statusCode.toString());
        print(response.body);
      }
    }catch(e){
      print(e);
    }
  }

  void _setBreed() async{

    String breed = "";

    await showDialog(
        context: context,
        builder: (BuildContext context){
      return Dialog(
        child: Row(
          children: [
            Padding(padding:EdgeInsets.only(right:10.0)),
            Expanded(
              child:TextFormField(
                decoration: InputDecoration(
                    hintText: 'What is the breed of your dog?'
                ),
                onChanged: (String newValue){breed = newValue;},
              ),
            ),
            IconButton(icon: Icon(Icons.done),
                onPressed: () async{
                  await _updateBreed(breed);
                  Navigator.pop(context);
                }),
            IconButton(icon: Icon(Icons.close), onPressed: (){Navigator.pop(context);})
          ],
        ),
      );
    }
    );
  }

  _updateBreed(String breed) async{
    try{
      final http.Response response = await http.put( //register to database
          'https://dogsonfire.herokuapp.com/dogs',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token))}'
          },
          body: jsonEncode(<String,String>{
            "name": widget.dog.name,
            "breed": breed,
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print("Updated breed, response code: " + response.statusCode.toString());
        setState(() {widget.dog.setBreed(breed);});
      }else{ //Something went wrong
        print("Something went wrong with updating breed: " + response.statusCode.toString());
        print(response.body);
      }
    }catch(e){
      print(e);
    }
  }

  _setDateOfBirth() async{ //TODO: FACTOR

    String dateOfBirth = "";

    DateTime _dateTime = DateTime.now();
    final f = new DateFormat('yyyy-MM-dd');
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return _buildBottomPicker(
          CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: DateTime.now(),
            maximumDate: DateTime.now(),
            onDateTimeChanged: (DateTime newDateTime) {
              if (mounted) {
                _dateTime = newDateTime;
                dateOfBirth = '${f.format(_dateTime)}';
              }
            },
          ),
        );
      },
    );

    dateOfBirth = '${f.format(_dateTime)}';

    _updateDateOfBirth(dateOfBirth);
  }

  Widget _buildBottomPicker(Widget picker) {

    double _kPickerSheetHeight = 216.0;

    return Container(
      height: _kPickerSheetHeight,
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

  _updateDateOfBirth(String dateOfBirth)async{
    try{

      final http.Response response = await http.put( //register to database
          'https://dogsonfire.herokuapp.com/dogs',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token))}'
          },
          body: jsonEncode(<String,String>{
            "name":widget.dog.name,
            "dateOfBirth": dateOfBirth,
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print("Updated date of birth, response code: " + response.statusCode.toString());
        setState(() {dog.setDateOfBirth(dateOfBirth);});
      }else{ //Something went wrong
        print("Something went wrong with updating date of birth, response code: " + response.statusCode.toString());
        print(response.body);
      }
    }catch(e){
      print(e);
    }
  }

  void _updateNeutered(String neutered) async{
    bool neut;
    if(neutered == 'Yes'){
      neut = true;
    }else{
      neut = false;
    }

    try{

      final http.Response response = await http.put( //register to database
          'https://dogsonfire.herokuapp.com/dogs',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token))}'
          },
          body: jsonEncode(<String,String>{
            "name":widget.dog.name,
            "neutered":neut.toString(),
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print("Updated neutered, response code: " + response.statusCode.toString());
        setState(() {widget.dog.setNeutered(neut);});
      }else{ //Something went wrong
        print("Something went wrong with updating neutered, response code: " + response.statusCode.toString());
        print(response.body);
      }
    }catch(e){
      print(e);
    }
  }

  void _updateGender(String gender) async{
    try{

      final http.Response response = await http.put( //register to database
          'https://dogsonfire.herokuapp.com/dogs',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token))}'
          },
          body: jsonEncode(<String,String>{
            "name":widget.dog.name,
            "gender":gender,
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print("Updated gender, response code: " + response.statusCode.toString());
        setState(() {widget.dog.setGender(gender);});
      }else{ //Something went wrong
        print("Something went wrong with updating gender, response code: " + response.statusCode.toString());
        print(response.body);
      }
    }catch(e){
      print(e);
    }
  }

  void _setDescription(String desc) async{
    try{

      final http.Response response = await http.put( //register to database
          'https://dogsonfire.herokuapp.com/dogs',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token))}'
          },
          body: jsonEncode(<String,String>{
            "name":widget.dog.name,
            "description":desc,
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print("Updated desc, response code: " + response.statusCode.toString());
        setState(() {widget.dog.setDescription(desc);});
      }else{ //Something went wrong
        print("Something went wrong with updating desc, response code: " + response.statusCode.toString());
        print(response.body);
      }
    }catch(e){
      print(e);
    }
  }

}

enum ProfileState{About, Awards}