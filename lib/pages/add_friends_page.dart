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

import '../app_state_container.dart';
import '../models/app_state.dart';
import '../models/user.dart';
import '../models/invitation.dart';

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

  int _currentTabIndex;

  List<FirebaseUser> user;
  List<Friendship> _displayedFriendships;
  List<Invitation> _pendingPeople;

  @override
  void initState() {
    _displayedFriendships = List<Friendship>();
    _pendingPeople = List<Invitation>();
    _currentTabIndex = 0;

    super.initState();

  }


  _handleTabBar(int i) {
    if (i == 1) {
      setState(() {
              Storage.getPendingFriendRequests(appState.user.uuid)
                .then((invitations) => _pendingPeople = invitations)
                .catchError((e) => print(e));
                _currentTabIndex = 1;
            });
    } else {
      setState(() => _currentTabIndex = 0);
    }
    

  }

  buildPendingList() {
    return _pendingPeople.length > 0
        ? _pendingPeople.map((invitation) {
            return new ListCard(
              text: invitation.user.name,
              leadingIcon: new CircleAvatar(child: Text(invitation.user.name.substring(0,1))),
              // trailingIcon: Row(
              //   children: <Widget>[
              //     GestureDetector(
              //       onTap: (() => print('accept')),
              //       child: Icon(Icons.check_circle),
              //     ),
              //     GestureDetector(
              //       child: Icon(Icons.delete_forever),
              //       onTap: (() => print('delete')),
              //     ),
              //   ],
              // ) 
              trailingIcon: GestureDetector(
                onTap: (() {
                  Storage.acceptFriendRequest(invitation.invitationUID);
                  print('sent with ${invitation.invitationUID}');
                  setState(() {
                              Storage.getPendingFriendRequests(appState.user.uuid)
                              .then((invitations) => _pendingPeople = invitations)
                              .catchError((e) => print(e));        
                              });
                }),
                child: Icon(Icons.check_circle),
              ),
            );
          }).toList()
        : <Widget>[
            new ListTile(
              title: Text(
                'No friend requests :(',
                style: TextStyle(color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
              contentPadding: EdgeInsets.all(18.00),
            )
          ];
  }

  @override
  Widget build(BuildContext context) {
    appState = AppStateContainer.of(context).state;

    final search = new Column(
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
      );

    final pending = ListView(
      children: buildPendingList(),
    );

    

    return Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        title: new Text('Add Friends'),
      ),
      body: _currentTabIndex == 0 ? search : pending,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Find Friends'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            title: Text('Friend Requests'),
          )
        ],
        onTap: (int i) => _handleTabBar(i),
        currentIndex: _currentTabIndex,
      ),
    );
  }

  List<Widget> buildSuggestionsList() {
    return _displayedFriendships.length > 0
        ? _displayedFriendships.map((fs) {
            return new ListCard(
              text: fs.friend.name,
              leadingIcon: new CircleAvatar(child: Text(fs.friend.name.substring(0,1))),
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
