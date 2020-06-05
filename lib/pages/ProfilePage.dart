import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dog_prototype/dialogs/DogDialog.dart';
import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/pages/FriendPage.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/SettingsPage.dart';
import 'package:dog_prototype/pages/DogProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget{

  final User user;
  final bool newState;
  ProfilePage({this.user,this.newState});


  @override
  State createState() => new ProfileState();
}

class ProfileState extends State<ProfilePage>{

  User user;

  String profileImage;
  String snackText = "";

  bool _loadingImage = false;
  bool _loadingProfile = false;
  Widget loading = Center(child:CircularProgressIndicator());

  @override
  void initState() {
    if(user == null){
      user = widget.user;
    }
    _getProfileImage();
    super.initState();
  }

  _getProfileImage() async{
    dynamic result = await StorageProvider(user:user).getProfileImage();

    if(result != null){
      setState(() {
        profileImage = result.toString();
      });
    }

    setState(() {
      _loadingImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(user == null || profileImage == null){
      return loading;
    }else{
      return profile();
    }
  }

  Widget profile(){
    return _loadingProfile == true ?
    loading
        :
    Scaffold(
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
          Divider(thickness: 1.0,),
          _infoSection(),
        ],
      ),
    );
  }

  Widget _headerSection(){
    return Expanded(
      flex: 3,
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
            Spacer(),
            FlatButton(
                onPressed: () async{
                  print(await AuthService().getToken());
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => FriendPage(user: user)));
                },
                child: Text(
                  'Friends',
                  style: TextStyle(
                      fontSize: 18,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold
                  ),
                )
            ),
          ],
      ),
      ),
    );
  }

  Widget _infoSection(){
    return Expanded(
        flex: 7,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                title: Text('About', style: TextStyle(fontSize: 16)),
                trailing: IconButton(icon:Icon(Icons.edit), onPressed: (){_setDescription();}),
              ),

              Padding(padding: EdgeInsets.only(top:10),),
              GestureDetector(
                child: ListTile(title: Text(user.desc ?? 'Add a description of yourself')),
                onTap: (){_setDescription();}
              ),
              Divider(thickness: 1.0,),
              Padding(padding: EdgeInsets.only(top:10),),
              Row(
                children: <Widget>[
                  Text('My dogs:', style: TextStyle(fontSize: 17)),
                  IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async{
                        await showDialog(context: context, barrierDismissible: false, child: DogDialog(context));
                        setState(() {
                          _loadingProfile = true;
                        });
                        User newUser = await AuthService().createUserModel(AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken()));
                        setState(() {user = newUser; _loadingProfile = false;});
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
      flex: 7,
      child: ListView.builder(
        itemCount: user.dogs.length,
        itemBuilder: (context, index) {
          return ListTile(
              leading: Icon(Icons.pets),
              title: Text(user.dogs[index]['name']),
              //TODO: IMAGE URL
              trailing: IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: (){
                    Dog dog = Dog.fromJson(user.dogs[index]);
                    _deleteDogConfirmation(dog);
                  }
                  ),
              onTap: (){
                Dog dog = Dog.fromJson(user.dogs[index]);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => DogProfile(dog:dog)));
              });
        },
      ),
    );
  }

  Future getImage() async{

    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _loadingImage = true;
    });

    bool uploadSuccessful = await StorageProvider(user:user).uploadImage(tempImage);
    if(uploadSuccessful){
      //_getProfileImage();
      dynamic result = await StorageProvider(user:user).getProfileImage();
      if(result != null){
        _getProfileImage();
      }
    }else{
      String snackText = "Something went wrong with uploading picture.";

      Scaffold.of(context).showSnackBar(SnackBar(content: Text(snackText)));

      setState(() {_loadingImage = false;});
    }
  }

  _setDescription() async{
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
                              onPressed: (){_updateDescription(desc); setState(() {_loadingProfile = true;}); Navigator.pop(context);},
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

  void _updateDescription(String desc) async{
    try{

      final http.Response response = await http.put( //register to database
          'https://dogsonfire.herokuapp.com/users',
          headers:<String, String>{
            "Accept": "application/json",
            'Content-Type' : 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token))}'
          },
          body: jsonEncode(<String,String>{
            "name":widget.user.username,
            "description":desc,
          })
      );

      if(response.statusCode==200){ // Successfully created database account
        print("Updated desc, response code: " + response.statusCode.toString());
        setState(() {widget.user.setDescription(desc); _loadingProfile = false;});
      }else{ //Something went wrong
        print("Something went wrong with updating desc, response code: " + response.statusCode.toString());
        print(response.body);
        setState(() {_loadingProfile = false;});
      }
    }catch(e){
      setState(() {_loadingProfile = false;});
      print(e);
    }
  }

  _deleteDogConfirmation(Dog dog)async{
    await showDialog(
        context: context,
        child: SimpleDialog(
          contentPadding: EdgeInsets.all(10.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Are you sure that you want to delete ${dog.name} from your profile?',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top:20),
                  child: ListTile(
                      leading: RaisedButton(
                          child: Text('No'),
                          onPressed: (){Navigator.pop(context);},
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)))
                      ,
                      trailing: RaisedButton(
                          child: Text('Yes'),
                          onPressed: () async{
                            setState(() {_loadingProfile = true;});
                            Navigator.pop(context);
                            await _deleteDog(dog);
                            setState(() {
                              _loadingProfile = true;
                            });
                            User newUser = await AuthService().createUserModel(AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken()));
                            setState(() {user = newUser; _loadingProfile = false;});
                          },
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)))
                  ),
                ),
              ],
            ),
          ],
        )
    );
  }

  _deleteDog(Dog dog)async{
    String token = await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token));

    try{
      final response = await http.delete('https://dogsonfire.herokuapp.com/dogs/${dog.uuid}', headers:{'Authorization': 'Bearer $token'});
      if(response.statusCode == 204){
        print(response.statusCode);

        setState(() {
          _loadingProfile = false;
        });
        snackText = 'Successfully deleted ${dog.name} from your profile.';
      }else{
        print(response.statusCode);
        print(response.body);

        setState(() {
          _loadingProfile = false;
        });
        snackText = 'Something went wrong with deleting ${dog.name} from your profile.';
      }
    }catch(e){
      print(e);
      setState(() {
        _loadingProfile = false;
      });
      snackText = 'Something went wrong with deleting ${dog.name} from your profile.';
    }

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(snackText)));
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
