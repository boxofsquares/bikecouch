import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

import '../components/list_card.dart';
import '../components/pill_button.dart';
import '../components/fade_animation_widget.dart';
import '../utils/storage.dart';
import '../models/user.dart';

import '../models/app_state.dart';
import '../app_state_container.dart';

class TargetList extends StatefulWidget {
  final List<String> challenge;

  TargetList({Key key, this.challenge}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TargetListState();
  }
}

class TargetListState extends State<TargetList>
    with SingleTickerProviderStateMixin {
  AppState appState;

  List<String> _targetUIDs;
  String _searchExpression;

  Animation placeholderAnimation;
  AnimationController placeholderAnimationController;

  @override
  void initState() {
    _targetUIDs = List<String>();
    _searchExpression = '';
    setupPlaceholderAnimation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var container = AppStateContainer.of(context);
    appState = container.state;

    return Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        title: new Text('Pick Your Target!'),
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
                  hintText: 'Start typing a friend\'s name...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 24.00, horizontal: 32.00),
                  border: InputBorder.none,
                ),
              )),
          new Expanded(
            child: buildFriendList(),
          ),
        ],
      ),
      floatingActionButton: _targetUIDs.length > 0
          ? PillButton(
              text: 'Send the challenge!',
              onTap: () => sendChallenge(),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildFriendList() {
    return new StreamBuilder(
      stream: Storage.friendsStreamFor(appState.user.uuid),
      builder: (BuildContext context, AsyncSnapshot<List<User>> snap) {
        List<Widget> listItems;
        if (snap.hasData) {
          if (placeholderAnimationController.isAnimating) {
            placeholderAnimationController.stop();
          }
          if (snap.data.length == 0) {
            listItems = <Widget>[
              new ListTile(
                title: Text(
                  'Sorry, noo friends here :(',
                  style: TextStyle(color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
                contentPadding: EdgeInsets.all(18.00),
              )
            ];
          } else {
            listItems = snap.data.where((user) {
              return user.name.indexOf(_searchExpression) > -1;
            }).map((user) {
              return new ListCard(
                isSelected: _targetUIDs.contains(user.uuid),
                text: user.name,
                onTap: () => selectTarget(user.uuid),
                leadingIcon:
                    new CircleAvatar(child: Text(user.name.substring(0, 1))),
              );
            }).toList();
          }
        } else {
          placeholderAnimationController.forward();
          listItems = generateWordPairs().take(3).map((wp) {
            return new FadeTransitionWidget(
              child: new ListCard(
                text: wp.asPascalCase,
                enabled: false,
                leadingIcon: new Icon(Icons.person_outline),
              ),
              animation: placeholderAnimation,
            );
          }).toList();
        }
        return ListView(
          children: listItems,
        );
      },
    );
  }

  void selectTarget(String friendUID) {
    setState(() {
      if (_targetUIDs.contains(friendUID)) {
        _targetUIDs.remove(friendUID);
      } else {
        _targetUIDs.add(friendUID);
      }
    });
  }

  void onSearchChanged(String input) {
    setState(() {
      _searchExpression = input;
    });
  }

  void sendChallenge() {
    Storage.sendChallengeFromToMany(
        appState.user.uuid, _targetUIDs, widget.challenge);
    Navigator.pop(context, true);
  }

  void setupPlaceholderAnimation() {
    // Placeholder animation setup
    placeholderAnimationController = new AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    final CurvedAnimation curve = CurvedAnimation(
        parent: placeholderAnimationController, curve: Curves.linear);
    placeholderAnimation = Tween(begin: 1.0, end: 0.2).animate(curve);
    placeholderAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        placeholderAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        placeholderAnimationController.forward();
      }
    });
  }
}
