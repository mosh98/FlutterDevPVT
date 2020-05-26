import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/SettingsPage.dart';
import 'package:dog_prototype/pages/DogProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget{

  final User user;
  ProfilePage({this.user});

  @override
  State createState() => new ProfileState();
}

class ProfileState extends State<ProfilePage>{

  File _image;
  User user;

  List<String> images = [ //TODO: DELETE AFTER FIXED PICTURES.
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
  ];

  @override
  void initState() {
    if(user == null){
      user = widget.user;
    }
    super.initState();
  }

  Widget _loading = CircularProgressIndicator();

  @override
  Widget build(BuildContext context) {
    if(user == null){
      return _loading;
    }else{
      return profile();
    }
  }

  Widget profile(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Profile'),
        centerTitle: true,
        actions: <Widget>[
          FlatButton.icon(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage(user: user)));
            },
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            label: Text(
              'Settings',
              style: TextStyle(color:Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _headerSection(),

          _infoSection(),

          _pictureSection(),
        ],
      ),
    );
  }

  Widget _headerSection(){
    return Expanded(
      flex: 2,
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            GestureDetector(
                onTap: getImage,
                child: _image == null
                    ? CircleAvatar(radius: 40, child: Icon(Icons.add_a_photo, color: Colors.white), backgroundColor:Colors.grey)
                    : CircleAvatar(radius: 40, backgroundImage: FileImage(_image))
            ),
            Padding(padding: EdgeInsets.only(left: 10),),
            Text(user.username, style: TextStyle(fontSize: 16),)
          ],
        ),
      ),
    );
  }

  Widget _infoSection(){
    return Expanded(
        flex: 6,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('About', style: TextStyle(fontSize: 16)),
              Padding(padding: EdgeInsets.only(top:10),),
              Text(user.desc ?? 'Add a description of yourself'),
              Padding(padding: EdgeInsets.only(top:10),),
              Row(
                children: <Widget>[
                  Text('My dogs:', style: TextStyle(fontSize: 17)),
                  IconButton(icon: Icon(Icons.add),onPressed: (){_addDog();},iconSize: 16)
                ],
              ),
              _dogSection()
            ],
          ),
        )
    );
  }

  Widget _dogSection(){
    return Expanded(
      flex: 12,
      child: ListView.builder(
        itemCount: user.dogs.length,
        itemBuilder: (context, index) {
          return ListTile(
              leading: Icon(Icons.pets),
              title: Text(user.dogs[index]['name']),
              //TODO: IMAGE URL
              onTap: (){
                Dog dog = Dog.fromJson(user.dogs[index]);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => DogProfile(dog:dog)));
              });
        },
      ),
    );
  }

  Widget _pictureSection(){
    return Expanded(
      flex: 2,
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        itemCount: images.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          return (
              GestureDetector(
                onTap: ()
                async {
                  await showDialog(
                      context: context,
                      builder: (_) => ImageDialog()
                  );
                },
                child: Image(
                  image: AssetImage(images[index]),
                ),
              )
          );
        },
      ),
    );
  }

  double _kPickerSheetHeight = 75.0;
  double _kPickersheetWidth = 250.0;
  String gender = 'MALE'; //DEFAULT
  void _addDog() async{

    String dogName = "";
    String breed = "";
    String dateOfBirth = "";

    DateTime _dateTime = DateTime.now();
    final f = new DateFormat('yyyy-MM-dd');

    await showDialog(context: context,
        barrierDismissible: false,
        child: ListView(
          children: [
            AlertDialog(
                content: Stack(
                  overflow: Overflow.visible,
                  children: [
                    Positioned(
                      right: -40.0,
                      top: -40.0,
                      child: InkResponse(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop('dialog');
                          Navigator.of(context).pop();
                        },
                        child: CircleAvatar(
                          child: Icon(Icons.close),
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                    Padding(padding:EdgeInsets.only(top:10.0)),
                    Text('Information about your dog', style:TextStyle(fontSize: 17.0)),
                    Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(padding:EdgeInsets.only(top:20.0)),
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Name*'
                              ),
                              onChanged: (String value){dogName = value;},
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Breed*'
                              ),
                              onChanged: (String value){breed = value;},
                            ),
                            _buildBottomPicker(
                              CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.date,
                                initialDateTime: DateTime.now(),
                                maximumDate: DateTime.now(),
                                onDateTimeChanged: (DateTime newDateTime) {
                                  if (mounted) {
                                    _dateTime = newDateTime;
                                    print("You Selected Date: ${newDateTime}");
                                    dateOfBirth = '${f.format(_dateTime)}';
                                  }
                                },
                              ),),
                            DropdownButton<String>(
                              value: gender,

                              onChanged: (String newValue) {setState(() {
                                setState(() {
                                  gender = newValue;
                                });

                                print(gender);
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
                            Center(
                              child: RaisedButton(
                                onPressed: (){Navigator.of(context).pop();},
                                child: Text('Add dog'),
                                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                              ),
                            ),
                          ],
                        )
                    )
                  ],
                )
            ),
          ],
        )
    );

    print(dogName + " " + breed + " " + dateOfBirth + " " + gender);

    if(dogName.isEmpty || breed.isEmpty || dateOfBirth.isEmpty || gender.isEmpty){
      return; //todo. error message
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
            'neutered':null,
            'description':null,
          })
      );

      if(response.statusCode==201){
        User newUser = await AuthService().createUserModel(AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken()));
        setState(() {user = newUser;});
      }else{
        print(response.statusCode);
        print(response.body);
      }
    }catch(e){
      print(e);
    }
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

  Future getImage() async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }
}

class ImageDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: ExactAssetImage('assets/pernilla.jpg'),
                fit: BoxFit.cover
            )
        ),
      ),
    );
  }
}

