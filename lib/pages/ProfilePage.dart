import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dog_prototype/loaders/DefaultLoader.dart';
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

  User user;

  String profileImage;

  bool _loadingImage = false;

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
    _getProfileImage();
    super.initState();
  }

  _getProfileImage() async{
    String token = await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token));
    try{
      final url = await http.get('https://dogsonfire.herokuapp.com/images/${user.userId}', headers:{'Authorization': 'Bearer $token'});
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

  Widget _loading = DefaultLoader();

  @override
  Widget build(BuildContext context) {
    if(user == null || profileImage == null){
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
            Padding(padding: EdgeInsets.only(left: 10),),
            Text(user.username, style: TextStyle(fontSize: 16),),
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
                  IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async{
                        await showDialog(context: context, barrierDismissible: false, child: DogDialog());
                        User newUser = await AuthService().createUserModel(AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken()));
                        print(newUser.toString());
                        setState(() {user = newUser;});
                        print(newUser.toString());
                      },
                      iconSize: 16
                  )
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

  Future<bool> _uploadImage(File image) async{
    try{
      String token = await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token));

      final response = await http.put('https://dogsonfire.herokuapp.com/images/${user.userId}', headers:{'Authorization': 'Bearer $token'});

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

class DogDialog extends StatefulWidget{
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
                            style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: Colors.black.withOpacity(0.4))),
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
                      onPressed: ()async{await _addDog();Navigator.of(context).pop();},
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
    if(dateOfBirth.isEmpty){
      dateOfBirth = f.format(_dateTime);
    }

    if(dogName.isEmpty || breed.isEmpty || gender.isEmpty){
      print('wrong inputs');
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
        print(response.statusCode);
      }else{
        print(response.statusCode);
        print(response.body);
      }
    }catch(e){
      print(e);
    }
  }
}

