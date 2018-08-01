import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:english_words/english_words.dart';

// Custom Packages
import '../components/list_card.dart';
import '../components/fade_animation_widget.dart';
import '../utils/storage.dart';
import '../models/user.dart';
import '../models/friendship.dart';
import '../models/app_state.dart';
import '../app_state_container.dart';

class AddFriendsPage extends StatefulWidget {
  AddFriendsPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddFriendsPageState();
  }
}

class AddFriendsPageState extends State<AddFriendsPage>
    with SingleTickerProviderStateMixin {
  AppState appState;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<FirebaseUser> user;
  List<Friendship> _displayedFriendships;

  @override
  void initState() {
    _displayedFriendships = List<Friendship>();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    appState = AppStateContainer.of(context).state;
    return Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        title: new Text('Search for New Friends'),
      ),
      body: new Column(
        children: <Widget>[
          new Container(
              decoration: new BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                color: Colors.grey[300],
              ))),
              child: new TextField(
                autocorrect: false,
                keyboardType: TextInputType.text,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Start typing a name...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 24.00, horizontal: 32.00),
                  border: InputBorder.none,
                ),
              )),
          new Expanded(
            child: new ListView(
              children: buildSuggestionsList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildSuggestionsList() {
    return _displayedFriendships.length > 0
        ? _displayedFriendships.map((fs) {
            return new ListCard(
              text: fs.friend.name,
              leadingIcon: new Icon(Icons.person),
              trailingIcon: fs.friendshipStatus == FriendshipStatus.Strangers ? IconButton(
                  icon: Icon(Icons.person_add),
                  onPressed: () {
                      sendFriendInvitation(fs.friend.uuid);
                      setState(() {
                      fs.friendshipStatus = FriendshipStatus.Pending; 
                      });
                    }
                  ): null,
            );
          }).toList()
        : <Widget>[
            new ListTile(
              title: Text(
                'No results. :(',
                style: TextStyle(color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
              contentPadding: EdgeInsets.all(18.00),
            )
          ];
  }

  void sendFriendInvitation(String inviteeUID) async {
    Storage.sendFriendInvitation(appState.user.uuid, inviteeUID);
  }

  void onSearchChanged(String input) {
    Storage.getFriendShipsByDisplayNameWith(input, appState.user.uuid).then( (friendships) {
     setState(() {
      _displayedFriendships  = friendships;
     });
    });
  }
}
