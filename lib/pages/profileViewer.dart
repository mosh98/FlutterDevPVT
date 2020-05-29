import 'dart:collection';
import 'dart:convert';

import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/DogProfile.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/pages/DogProfileViewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image/network.dart';

class profileViewer extends StatefulWidget{

  @override
  ProfileState createState() => ProfileState();

    profileViewer({@required this.otherUser});
    final User otherUser;
}

class ProfileState extends State<profileViewer>{

List<String> images = [ //TODO: DELETE AFTER FIXED PICTURES.
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
    'assets/pernilla.jpg',
  ];

Widget _loading = DefaultLoader();
String profileImage;


  @override
  void initState(){
    evictImage();
    _getProfileImage();
    super.initState();
  }

void evictImage(){
  final NetworkImage provider = NetworkImage(widget.otherUser.photoUrl);
  provider.evict().then<void>((bool success){
    if(success)
      debugPrint('removed image');
  });
}

_getProfileImage() async{
  String token = await AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken().then((value) => value.token));
  try{
    final url = await http.get('https://dogsonfire.herokuapp.com/images/profiles/${widget.otherUser.userId}', headers:{'Authorization': 'Bearer $token'});
    if(url != null){
      print(url.body);
      setState(() {
        profileImage = url.body;
      });
    }else{
      print(url.body);
      setState(() {
        profileImage = widget.otherUser.photoUrl;
      });
    }
  }catch(e){
    print(e);
  }
}

@override
Widget build(BuildContext context) {
  if(widget.otherUser == null || profileImage == null){
    return _loading;
  }else{
    return _profile();
  }
}

  Widget _profile(){

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text(widget.otherUser.username),
        centerTitle: true,
        actions: <Widget>[
          FlatButton.icon(
            onPressed: (){
            },
            icon: Icon(
              Icons.person_add,
              color: Colors.white,
            ),
            label: Text(
              'Add Friend',
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
//            CircleAvatar(
//                radius: 40,
//                backgroundImage: NetworkImage(widget.otherUser.photoUrl),
//            ),
            CircleAvatar(radius: (52),
                backgroundColor: Colors.white,
                child: ClipRRect(
                  borderRadius:BorderRadius.circular(50),
                  child: CircleAvatar(
                    radius: 52,
                    backgroundImage: NetworkImage(profileImage),
                  ),
                )
            ),
            Padding(padding: EdgeInsets.only(left: 10),),
            Text(widget.otherUser.username, style: TextStyle(fontSize: 16),)
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
            Text(widget.otherUser.desc ?? ''),
            Padding(padding: EdgeInsets.only(top:10),),
            Row(
              children: <Widget>[
                Text(widget.otherUser.username + 's dogs:', style: TextStyle(fontSize: 17)),
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
      itemCount: widget.otherUser.dogs.length,
      itemBuilder: (context, index) {
        return ListTile(
            leading: Icon(Icons.pets),
            title: Text(widget.otherUser.dogs[index]['name']),
            //TODO: IMAGE URL
            onTap: (){
              Dog dog = Dog.fromJson(widget.otherUser.dogs[index]);
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => DogProfileViewer(dog:dog))); //TODO: NEED TO CHANGE
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

  void _addDog(User user) async{

    String dogName = "";

    await showDialog(context: context,
    child: AlertDialog(
    title: Text('What is the name of your dog?'),
    content: SingleChildScrollView(
    child: TextFormField(
    onChanged: (value){dogName = value;},
    ),
    ),
    actions: <Widget>[
    MaterialButton(
    child: Text('Add dog'),
    onPressed: (){Navigator.of(context).pop();},
    ),
    MaterialButton(
    child: Text('Back'),
    onPressed: (){Navigator.of(context).pop(); return;},
    )
    ],
    )
    );

    if(dogName.isEmpty){
      return; //todo. error message
    }
    
    try{
      final http.Response response = await http.post(
          'https://redesigned-backend.herokuapp.com/user/dog/register?owner=${user.username}',
          headers:<String, String>{
            'Content-Type' : 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String,String>{
            'name':dogName,
            'age':null,
            'breed':'Not set',
            'gender':'Not set',
            'description':'not set',
          })
      );

      if(response.statusCode==200){
        print(response.body);
      }else{
        print('semething wrong');
      }
    }catch(e){
      print(e);
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