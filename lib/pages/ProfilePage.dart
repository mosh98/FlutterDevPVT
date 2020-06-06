import 'package:cached_network_image/cached_network_image.dart';
import 'package:dog_prototype/dialogs/DogDialog.dart';
import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/pages/FriendPage.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/services/HttpProvider.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/SettingsPage.dart';
import 'package:dog_prototype/pages/DogProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget{

  final User user;
  final bool newState;
  final StorageProvider storageProvider;
  final HttpProvider httpProvider;
  ProfilePage({this.user,this.newState, this.storageProvider, this.httpProvider});


  @override
  State createState() => new ProfileState();
}

class ProfileState extends State<ProfilePage>{

  User user;

  String profileImage;
  String snackText = "";

  bool _loadingImage = true;
  bool _loadingProfile = false;
  Widget loading = Center(child:CircularProgressIndicator());

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    user = widget.user;
    _getProfileImage();
    super.initState();
  }

  _getProfileImage() async{
    dynamic result = await widget.storageProvider.getProfileImage();

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
    if(user == null || _loadingImage == true){
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
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Profile'),
        centerTitle: true,
        actions: <Widget>[
          FlatButton.icon(
            key: Key('settings'),
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
                        key: Key('imageholder'),
                        borderRadius: BorderRadius.circular(10000.0),
                        child: _loadingImage == true ?
                        DefaultLoader()
                        :
                        profileImage != null ?
                        CachedNetworkImage(
                            imageUrl: profileImage,
                            placeholder: (context, url) => DefaultLoader(),
                            errorWidget: (context, url, error) => CircleAvatar(radius: 60, child: Icon(Icons.add_a_photo, color: Colors.white), backgroundColor:Colors.grey)
                        )
                         :
                        CircleAvatar(radius: 60, child: Icon(Icons.add_a_photo, color: Colors.white), backgroundColor:Colors.grey)
                    )
                )
            ),
            Padding(padding: EdgeInsets.only(left: 10),),
            Text(user.username, style: TextStyle(fontSize: 16),),
            Spacer(),
            FlatButton(
              key:Key('friends'),
                onPressed: () async{
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
                key: Key('about'),
                title: Text('About', style: TextStyle(fontSize: 16)),
                trailing: IconButton(
                    key: Key('edit'),
                    icon:Icon(Icons.edit),
                    onPressed: (){_setDescription();}
                    ),
              ),

              Padding(padding: EdgeInsets.only(top:10),),
              GestureDetector(
                key: Key('aboutgesture'),
                child: ListTile(title: Text(user.desc ?? 'Add a description of yourself')),
                onTap: (){_setDescription();}
              ),
              Divider(thickness: 1.0,),
              Padding(padding: EdgeInsets.only(top:10),),
              Row(
                children: <Widget>[
                  Text('My dogs:', style: TextStyle(fontSize: 17), key: Key('mydogs'),),
                  IconButton(
                    key: Key('addog'),
                      icon: Icon(Icons.add),
                      onPressed: () async{
                        dynamic result = await showDialog(context: context, barrierDismissible: false, child: DogDialog(context,widget.httpProvider));

                        if(result != null){
                          setState(() {
                            _loadingProfile = true;
                          });

                          Dog dog = result;

                          widget.user.addDog(dog);
                          setState(() {
                            user = widget.user;
                            _loadingProfile = false;
                          });
                          snackText = "Your dog was added to your profile!";
                          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText)));
                        }

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
        key: Key('doglistview'),
        itemCount: user.dogs.length,
        itemBuilder: (context, index) {
          return ListTile(
              leading: Icon(Icons.pets),
              title: Text(user.dogs[index].getName()),
              trailing: IconButton(
                key: Key('removedog${user.dogs[index].getUUID()}'),
                  icon: Icon(Icons.delete_forever),
                  onPressed: (){
                    Dog dog = user.dogs[index];
                    _deleteDogConfirmation(dog);
                  }
                  ),
              onTap: (){
                Dog dog = user.dogs[index];
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

    bool uploadSuccessful = await widget.storageProvider.uploadImage(tempImage);
    if(uploadSuccessful){
      dynamic result = await widget.storageProvider.getProfileImage();
      if(result != null){
        _getProfileImage();
      }
    }else{
      String snackText = "Something went wrong with uploading picture.";

      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackText)));

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
                            key: Key('editdesctextfield'),
                            keyboardType: TextInputType.multiline,
                            maxLines: 7,
                            maxLength: 100,
                            onChanged: (String input){
                              desc = input;
                            },
                          ),
                          ListTile(
                            leading: IconButton(
                              key: Key('dialogeditbuttondone'),
                              icon: Icon(Icons.done),
                              onPressed: (){_updateDescription(desc); setState(() {_loadingProfile = true;}); Navigator.pop(context);},
                            ),
                            trailing: IconButton(
                              key: Key('dialogeditbuttonback'),
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

    dynamic result = await widget.httpProvider.updateDescriptionUser(desc);

    if(result == true){
      setState(() {widget.user.setDescription(desc); _loadingProfile = false;});
    }else{
      setState(() {_loadingProfile = false;});
    }
  }

  _deleteDogConfirmation(Dog dog)async{
    await showDialog(
        context: context,
        child: SimpleDialog(
          key: Key('deletedogdialog'),
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
                    key: Key('information'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top:20),
                  child: ListTile(
                      leading: RaisedButton(
                          key: Key('nobutton'),
                          child: Text('No'),
                          onPressed: (){Navigator.pop(context);},
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)))
                      ,
                      trailing: RaisedButton(
                          key: Key('yesbutton'),
                          child: Text('Yes'),
                          onPressed: () async{
                            setState(() {_loadingProfile = true;});
                            Navigator.pop(context);
                            await _deleteDog(dog);
                            //User newUser = await AuthService().createUserModel(AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken()));
                            setState(() {
                              _loadingProfile = false;
                              user = widget.user;
                            });
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
    dynamic result = await widget.httpProvider.deleteDog(dog);
    if(result != null){
      if(result == true){
        widget.user.removeDog(dog);
        snackText = 'Successfully deleted ${dog.name} from your profile.';
      }else{
        snackText = 'Something went wrong with deleting ${dog.name} from your profile.';
      }
    }else{
      snackText = 'Something went wrong with deleting ${dog.name} from your profile.';
    }
    print(snackText);
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
