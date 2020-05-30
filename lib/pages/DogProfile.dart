import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class DogProfile extends StatefulWidget {

  final Dog dog;
  DogProfile({this.dog});

  @override
  _DogProfileState createState() => _DogProfileState();
}

class _DogProfileState extends State<DogProfile> {

  ProfileState _state = ProfileState.About;
  Dog dog;
  bool _loading = false;
  bool _loadingImage = false;
  String profileImage;


  @override
  void initState() {
    if(dog == null){
      dog = widget.dog;
    }
    _getProfileImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(profileImage == null){
      return DefaultLoader();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Dog Profile'),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        progressIndicator: DefaultLoader(),
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pictureSection(),
              _informationSection(),
            ],
          ),
        ),
      ),
    );
  }



  Widget _pictureSection(){
    return Expanded(
      flex: 1,
      child: Center(
        child: GestureDetector(
            onTap: getImage,
            child: Container(
                height:100,
                width:100,
                child:
                ClipRRect(
                    borderRadius: BorderRadius.circular(10000.0),
                    child: _loadingImage == true ?
                    DefaultLoader()
                        :
                    CachedNetworkImage(
                        imageUrl: profileImage,
                        placeholder: (context, url) => DefaultLoader(),
                        errorWidget: (context, url, error) => CircleAvatar(radius: 60, child: Icon(Icons.add_a_photo, color: Colors.white), backgroundColor:Colors.grey))
                )
            )
        ),
      ),
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
         Expanded( //TODO
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
                trailing: Text(dog.name ?? 'No name specified.'),
                onTap: (){_setName();},
            ),
            ListTile(
                title: Text('Breed:'),
                trailing: Text(dog.breed ?? 'No breed specified.'),
                onTap: (){_setBreed();},
            ),
            ListTile(
                title: Text('Date of birth:'),
                trailing: Text(dog.dateOfBirth ?? 'No date of birth specified.'),
                onTap: (){_setDateOfBirth();},
            ),
            ListTile(
                title: Text('Neutered:'),
                trailing: DropdownButton<String>(
                  value: dog.getNeutered(),
                  onChanged: (String newValue){_updateNeutered(newValue); },
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
                  value: dog.gender ?? 'MALE',
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
        Text(dog.description ?? 'Add a description to your dog!'),
      ],
    );
  }

  Future getImage() async{

    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _loadingImage = true;
    });

    bool uploadSuccessful = await _uploadImage(tempImage);
    if(uploadSuccessful){
      _getProfileImage();
    }else{
      String snackText = "Something went wrong with uploading picture.";

      Scaffold.of(context).showSnackBar(SnackBar(content: Text(snackText)));

      setState(() {_loadingImage = false;});
    }
  }

  Future<bool> _uploadImage(File image) async{
    try{
      String token = await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token));

      final response = await http.put('https://dogsonfire.herokuapp.com/images/${dog.uuid}', headers:{'Authorization': 'Bearer $token'});

      if(response != null){
        print('First put of picture-upload went through :' + response.statusCode.toString());
        print('Response body :' + response.body);
        try{
          final nextResponse = await http.put(response.body,
              body: image.readAsBytesSync());
          if(nextResponse.statusCode == 200){
            print('Second put of picture-upload went through :' + response.statusCode.toString());

            return true;
          }else{
            print('Something went wrong with uploading picture, second put: ' + response.statusCode.toString());
            //TODO: POPUP USER
            return false;
          }
        }catch(e){
          print(e);
          return false;
        }
      }else{
        print('Something went wrong with first put of profilepicture: ' + response.statusCode.toString());
        print(response.body);
        return false;
      }
    }catch(e){
      print(e);
      return false;
    }
  }


  _getProfileImage() async{
    String token = await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token));
    try{
      final url = await http.get('https://dogsonfire.herokuapp.com/images/${dog.uuid}', headers:{'Authorization': 'Bearer $token'});
      if(url.statusCode==200){
        setState(() {
          profileImage = url.body;
        });
      }
      setState(() {
        _loadingImage = false;
      });
    }catch(e){
      print(e);
      setState(() {
        _loadingImage = false;
      });
    }
  }

  _editDescription() async{

    String desc = "";

    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            Container(
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 7,
                    maxLength: 100,
                    onChanged: (String input){
                      desc = input;
                    },
                  ),
                  ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.done),
                      onPressed: (){_updateDescription(desc); setState(() {_loading = true;}); Navigator.pop(context);},
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: (){Navigator.pop(context);},
                    ),
                  )
                ],
              ),
            ),
          ]
        )
      );
    }
    );
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
                  Navigator.pop(context);
                  setState(() {
                    _loading = true;
                  });
                  await _updateName(name);
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
        setState(() {widget.dog.setName(name); _loading = false;});
      }else{ //Something went wrong
        print("Something went wrong with updating name: " + response.statusCode.toString());
        print(response.body);
        setState(() {_loading = false;});
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
                  setState(() {
                    _loading = true;
                  });
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
        setState(() {widget.dog.setBreed(breed); _loading=false;});
      }else{ //Something went wrong
        print("Something went wrong with updating breed: " + response.statusCode.toString());
        print(response.body);
        setState(() {_loading=false;});
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

    setState(() {_loading = true;});
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
        setState(() {dog.setDateOfBirth(dateOfBirth); _loading = false;});
      }else{ //Something went wrong
        print("Something went wrong with updating date of birth, response code: " + response.statusCode.toString());
        print(response.body);
        setState(() {_loading = false;});
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

    setState(() {_loading=true;});

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
        setState(() {widget.dog.setNeutered(neut); _loading = false;});
      }else{ //Something went wrong
        print("Something went wrong with updating neutered, response code: " + response.statusCode.toString());
        print(response.body);
        setState(() {_loading = false;});
      }
    }catch(e){
      print(e);
    }
  }

  void _updateGender(String gender) async{

    setState(() {_loading = true;});

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
        setState(() {widget.dog.setGender(gender); _loading = false;});
      }else{ //Something went wrong
        print("Something went wrong with updating gender, response code: " + response.statusCode.toString());
        print(response.body);
        setState(() {_loading=false;});
      }
    }catch(e){
      print(e);
    }
  }

  void _updateDescription(String desc) async{
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
        setState(() {widget.dog.setDescription(desc); _loading = false;});
      }else{ //Something went wrong
        print("Something went wrong with updating desc, response code: " + response.statusCode.toString());
        print(response.body);
        setState(() {_loading = false;});
      }
    }catch(e){
      print(e);
    }
  }

}

enum ProfileState{About, Awards}