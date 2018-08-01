import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:english_words/english_words.dart';

// Custom Packages
import '../components/list_card.dart';
import '../components/fade_animation_widget.dart';
import '../utils/storage.dart';

class AddFriendsPage extends StatefulWidget {
  AddFriendsPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddFriendsPageState();
  }
}

class AddFriendsPageState extends State<AddFriendsPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<FirebaseUser> user;

  List<String> _displayedPeople;

  @override
  void initState() {
    _displayedPeople = List<String>();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
    return _displayedPeople.length > 0
        ? _displayedPeople.map((userName) {
            return new ListCard(
              text: userName,
              leadingIcon: new Icon(Icons.person),
              trailingIcon: new IconButton(
                icon: Icon(Icons.person_add),
                onPressed: () => sendFriendInvitation() //TODO: invitee uid,
              ),
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

  void sendFriendInvitation() async {
    FirebaseUser currentUser = await _auth.currentUser();
    Storage.sendFriendInvitation(currentUser.uid, null);
  }

  void onSearchChanged(String input) {
    if (input.length > 2) {
      Storage.getUsersByDisplayNameWith(input).then( (names) {
        setState(() {
          _displayedPeople = names;
        });
      });
    }
  }

}
