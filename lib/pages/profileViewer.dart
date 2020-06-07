import 'package:cached_network_image/cached_network_image.dart';
import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/pages/DogProfileViewer.dart';
import 'package:dog_prototype/services/HttpProvider.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileViewer extends StatefulWidget{

  @override
  ProfileState createState() => ProfileState();

    ProfileViewer({@required this.otherUser, @required this.currentUser,this.storageProvider, this.httpProvider});
    final User otherUser;
    final User currentUser;
    final StorageProvider storageProvider;
    final HttpProvider httpProvider;
}

class ProfileState extends State<ProfileViewer> {

  Widget _loading = DefaultLoader();
  String profileImage;
  bool _loadingImage = false;
  bool _isFriends;

  @override
  void initState() {
    _getProfileImage();
    _getIsFriends();
    super.initState();
  }

  _getIsFriends() async{
    if(widget.currentUser.friends.contains(widget.otherUser)){
      setState(() {
        _isFriends = true;
      });
    }else{
      setState(() {
        _isFriends = false;
      });
    }
  }

  _getProfileImage() async {
    final result = await widget.storageProvider.getOtherProfileImage(widget.otherUser);

    if(result != null){
      setState(() {
        profileImage = result;
      });
    }

    setState(() {_loadingImage = false;});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.otherUser == null || profileImage == null || _isFriends == null) {
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
          _isFriends == true ?
          FlatButton.icon(
            onPressed: () async{
              setState(() {
                _isFriends = false;
              });

              bool notFriends = await _removeFriend();

              if(notFriends==false){
                setState(() {
                  _isFriends = true;
                });
              }
              },
            icon: Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
            label: Text(
              'Remove',
              style: TextStyle(color: Colors.white),
            ),
          )
          :
          FlatButton.icon(
            onPressed: () async{
              setState(() {
                _isFriends = true;
              });

              bool friends = await _addFriend();

              if(friends == false){
                setState(() {
                  _isFriends = false;
                });
              }
              },
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
              title: Text(widget.otherUser.dogs[index].getName()),
              onTap: () {
                Dog dog = widget.otherUser.dogs[index];
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        DogProfileViewer(dog: dog)));
              });
        },
      ),
    );
  }

  Future<bool> _addFriend() async{
    bool addedFriend = await widget.httpProvider.addFriend(widget.otherUser);
    if(addedFriend){
      widget.currentUser.addFriend(widget.otherUser);
    }
    return addedFriend;
  }

  Future<bool> _removeFriend() async{
    bool removedFriend = await widget.httpProvider.removeFriend(widget.otherUser);
    if(removedFriend){
      widget.currentUser.removeFriend(widget.otherUser);
    }
    return removedFriend;
  }
}