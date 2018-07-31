import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/list_card.dart';
import '../components/pill_button.dart';
import '../utils/storage.dart';

class TargetList extends StatefulWidget {
  final List<String> challenge;

  TargetList({Key key, this.challenge}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TargetListState();
  }
}

class TargetListState extends State<TargetList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<FirebaseUser> user;
  String _selectedTarget;
  List<String> _allFriends;
  List<String> displayedFriends;

  @override
  void initState() {
    _allFriends = List<String>();
    displayedFriends = List<String>();
    _selectedTarget = '';
    getAllFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        title: new Text('Pick Your Target!'),
      ),
      body: new Column(
        children: <Widget>[
          new Container(
              child: new TextField(
            autocorrect: false,
            keyboardType: TextInputType.text,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Start typing a friend\'s name...',
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.00, horizontal: 8.00),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                    style: BorderStyle.solid, color: Colors.grey[50]),
                borderRadius: BorderRadius.circular(0.00),
              ),
            ),
          )),
          new Expanded(
            child: new ListView(
              children: buildFriendList(),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedTarget != ''
          ? PillButton(
              text: 'Send the challenge!',
              onTap: () => null,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  List<Widget> buildFriendList() {
    return displayedFriends.length > 0 ?
      displayedFriends.map((friend) {
        return new ListCard(
          isSelected: _selectedTarget == friend,
          text: friend,
          onTap: selectTarget,
        );
      }).toList()
      :
      <Widget>[
        new ListTile(
          title: Text('No friends here :(', style: TextStyle(color: Colors.grey[400]), textAlign: TextAlign.center,),
          contentPadding: EdgeInsets.all(18.00),
        )
      ];
  }

  void selectTarget(String targetName) {
    setState(() {
      _selectedTarget = _selectedTarget == targetName ? '' : targetName;
    });
  }

  void getAllFriends() async {
    FirebaseUser currentUser = await _auth.currentUser();
    Storage.getFriendsByDisplayName(currentUser.uid).then((friends) {
      setState(() {
        _allFriends = friends;
        displayedFriends = _allFriends;
      });
    });
  }

  void onSearchChanged(String input) {
    setState(() {
      displayedFriends = _allFriends.where((friend) {
        return friend.indexOf(input) > -1;
      }).toList();
    });
  }
}
