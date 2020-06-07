import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/services/HttpProvider.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class DogProfile extends StatefulWidget {

  final Dog dog;
  final HttpProvider httpProvider;
  final StorageProvider storageProvider;
  DogProfile({this.dog, this.httpProvider, this.storageProvider});

  @override
  _DogProfileState createState() => _DogProfileState();
}

class _DogProfileState extends State<DogProfile> {

  Dog dog;
  bool _loading = false;
  bool _loadingImage = true;
  String profileImage;
  String snackText = "";
  final _scaffoldKey = GlobalKey<ScaffoldState>();


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
    return Scaffold(
      key: _scaffoldKey,
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
                    profileImage == null ?
                    CircleAvatar(radius: 60, child: Icon(Icons.add_a_photo, color: Colors.white), backgroundColor:Colors.grey)
                    :
                    CachedNetworkImage(
                        imageUrl: profileImage,
                        placeholder: (context, url) => DefaultLoader(),
                        errorWidget: (context, url, error) => CircleAvatar(radius: 60, child: Icon(Icons.add_a_photo, color: Colors.white), backgroundColor:Colors.grey)
                    )
                )
            )
        ),
      ),
    );
  }

  Widget _informationSection() {
    return Expanded(
     flex: 4,
     child: Column(
       children: [
         Expanded(
           flex: 7,
           child: aboutSection()
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
            dog.gender == 'MALE' ?
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
            )
                :
            Text(''),
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
            )
          ]
      ).toList(),
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
    dynamic result = await widget.storageProvider.uploadImageDog(widget.dog, image);
    if(result != null){
      return result;
    }
  }


  _getProfileImage() async{
    dynamic result = await widget.storageProvider.getProfileImageDog(widget.dog);

    if(result != null){
      setState(() {profileImage = result;});
    }
    setState(() {_loadingImage = false;});
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
    dynamic result = await widget.httpProvider.setNameDog(widget.dog, name);
    if(result != null){
      if(result == true){
        setState(() {widget.dog.setName(name);});
      }else{
        snackText = "Something went wrong with updating name.";
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText)));
      }
    }
    setState(() {_loading = false;});
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
    dynamic result = await widget.httpProvider.setBreed(widget.dog, breed);
    if(result != null){
      if(result == true){
        setState(() {widget.dog.setBreed(breed);});
    }else{
        snackText = "Something went wrong with updating breed.";
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText)));
      }
    }
    setState(() {_loading = false;});
  }

  _setDateOfBirth() async{

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
    dynamic result = await widget.httpProvider.setDateOfBirthDog(widget.dog, dateOfBirth);
    if(result != null){
      if(result == true){
        setState(() {widget.dog.setDateOfBirth(dateOfBirth);});
      }else{
        snackText = "Something went wrong with updating date of birth.";
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText)));
      }
    }
    setState(() {_loading = false;});
  }

  void _updateNeutered(String neutered) async{
    bool neut;

    if(neutered == 'Yes'){
      neut = true;
    }else{
      neut = false;
    }

    setState(() {_loading=true;});

    dynamic result = await widget.httpProvider.updateNeutered(widget.dog, neut);

    if(result != null){
      if(result == true){
        setState(() {widget.dog.setNeutered(neut);});
      }else{
        snackText = "Something went wrong with the update.";
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText)));
      }
    }
    setState(() {_loading = false;});
  }

  void _updateGender(String gender) async{

    setState(() {_loading = true;});

    dynamic result = await widget.httpProvider.setGenderDog(widget.dog, gender);

    if(result != null){
      if(result == true){
        setState(() {widget.dog.setGender(gender);});
      }else{
        snackText = "Something went wrong with updating gender.";
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText)));
      }
    }
    setState(() {_loading = false;});
  }

  void _updateDescription(String desc) async{
    dynamic result = await widget.httpProvider.setDescriptionDog(widget.dog, desc);

    if(result != null){
      if(result == true){
        setState(() {widget.dog.setDescription(desc);});
      }else{
        snackText = "Something went wrong with updating description.";
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText)));
      }
    }
    setState(() {_loading = false;});
  }
}