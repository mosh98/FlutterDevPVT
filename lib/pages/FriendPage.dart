import 'package:dog_prototype/loaders/DefaultLoader.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/MessengerHandler.dart';
import 'package:dog_prototype/pages/profileViewer.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/material.dart';

class FriendPage extends StatefulWidget {

  final User user;
  FriendPage({this.user});

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {

  User user;
  List<User> friends = List<User>();
  
  @override
  void initState() {
    _getCurrentUser();
    super.initState();
  }

  _getCurrentUser() async{
    user = await AuthService().createUserModel(AuthService().getCurrentFirebaseUser().then((value) => value.getIdToken()));
    friends = user.friends;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return user == null ?
    DefaultLoader()
          :
    Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Friends'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child:Column(
          children: [
            _searchSection(),
            Padding(padding: EdgeInsets.only(top:15),),
            _friendsSection()
          ],
        )
      ),
    );
  }

  Widget _searchSection(){
    return Expanded(
      flex: 1,
      child: TextFormField(
        decoration: InputDecoration(
            hintText: 'Search',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)))
        ),
        onChanged: (String input){
          setState(() {
            friends = filterSearch(input);
          });
        },
      ),
    );
  }

  Widget _friendsSection(){
    return Expanded(
      flex: 9,
      child: user == null ?
      Center(child: Text('You have no friends yet. Go back and use the find friends feature!'))
          :
      ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context,index){
            User friend = friends[index];
            return ListTile(
              title: Text(friend.username),
              trailing: FlatButton.icon(
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MessengerHandler(user: user,peer: friend)));
                  //Navigator.of(context).push(MaterialPageRoute(builder: (context) => MessengerX( currentUser, user)));
                },
                icon: Icon(
                    Icons.chat_bubble_outline, size: 30, color: Colors.black
                ),
                label: Text(
                  '',
                  style: TextStyle(color:Colors.white),
                ),
              ),
              onTap: (){
                user = null;
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileViewer(otherUser: friend))).whenComplete(_getCurrentUser);
              },
            );
          }
      )
    );
  }

  List<User> filterSearch(String input){
    List<User> searchQuery = List<User>();
    if(user.friends != null && user.friends.length != 0){
      user.friends.forEach((element) {
        if(element.username.contains(input)){
          searchQuery.add(element);
        }
      });
      return searchQuery;
    }
    return searchQuery;
  }
}
