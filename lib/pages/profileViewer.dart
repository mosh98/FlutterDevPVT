import 'package:cached_network_image/cached_network_image.dart';
import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/pages/DogProfileViewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileViewer extends StatefulWidget{

  @override
  ProfileState createState() => ProfileState();

    ProfileViewer({@required this.otherUser});
    final User otherUser;
}

class ProfileState extends State<ProfileViewer> {

  Widget _loading = DefaultLoader();
  String profileImage;
  bool _loadingImage = false;


  @override
  void initState() {
    _getProfileImage();
    super.initState();
  }

  _getProfileImage() async {
    String token = await AuthService().getCurrentFirebaseUser().then((value) =>
        value.getIdToken().then((value) => value.token));
    try {
      final url = await http.get(
          'https://dogsonfire.herokuapp.com/images/profiles/${widget.otherUser
              .userId}', headers: {'Authorization': 'Bearer $token'});
      if (url.statusCode == 200) {
        setState(() {
          profileImage = url.body;
        });
      }
      setState(() {
        _loadingImage = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _loadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.otherUser == null || profileImage == null) {
      return _loading;
    } else {
      return _profile();
    }
  }

  Widget _profile() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text(widget.otherUser.username),
        centerTitle: true,
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.person_add,
              color: Colors.white,
            ),
            label: Text(
              'Add Friend',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _headerSection(),

          _infoSection(),
        ],
      ),
    );
  }

  Widget _headerSection() {
    return Expanded(
      flex: 3,
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Container(
                height: 100,
                width: 100,
                child:
                ClipRRect(
                    borderRadius: BorderRadius.circular(10000.0),
                    child: _loadingImage == true ?
                    DefaultLoader()
                        :
                    CachedNetworkImage(
                        imageUrl: profileImage,
                        placeholder: (context, url) => DefaultLoader(),
                        errorWidget: (context, url, error) =>
                            CircleAvatar(radius: 60,
                                child: Icon(
                                  Icons.person, color: Colors.white, size: 60,),
                                backgroundColor: Colors.grey))
                )
            ),
            Padding(padding: EdgeInsets.only(left: 10),),
            Text(widget.otherUser.username, style: TextStyle(fontSize: 16),)
          ],
        ),
      ),
    );
  }

  Widget _infoSection() {
    return Expanded(
        flex: 7,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('About', style: TextStyle(fontSize: 16)),
              Padding(padding: EdgeInsets.only(top: 10),),
              Text(widget.otherUser.desc ?? ''),
              Padding(padding: EdgeInsets.only(top: 10),),
              Row(
                children: <Widget>[
                  Text(widget.otherUser.username + 's dogs:',
                      style: TextStyle(fontSize: 17)),
                ],
              ),
              _dogSection()
            ],
          ),
        )
    );
  }

  Widget _dogSection() {
    return Expanded(
      flex: 7,
      child: ListView.builder(
        itemCount: widget.otherUser.dogs.length,
        itemBuilder: (context, index) {
          return ListTile(
              leading: Icon(Icons.pets),
              title: Text(widget.otherUser.dogs[index]['name']),
              //TODO: IMAGE URL
              onTap: () {
                Dog dog = Dog.fromJson(widget.otherUser.dogs[index]);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        DogProfileViewer(dog: dog))); //TODO: NEED TO CHANGE
              });
        },
      ),
    );
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