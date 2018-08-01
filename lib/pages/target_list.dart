import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:english_words/english_words.dart';
import 'dart:async';

import '../components/list_card.dart';
import '../components/pill_button.dart';
import '../components/fade_animation_widget.dart';
import '../utils/storage.dart';

class TargetList extends StatefulWidget {
  final List<String> challenge;

  TargetList({Key key, this.challenge}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TargetListState();
  }
}

class TargetListState extends State<TargetList> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<FirebaseUser> user;
  String _selectedTarget;
  List<String> _allFriends;
  List<String> displayedFriends;
  bool _isLoading;

  Animation placeholderAnimation;
  AnimationController placeholderAnimationController;

  @override
  void initState() {
    _isLoading = true;
    _allFriends = List<String>();
    displayedFriends = List<String>();
    _selectedTarget = '';
    setupPlaceholderAnimation();
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
            decoration: new BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300],))),
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
            )
          ),
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
    if (_isLoading) {
      placeholderAnimationController.forward();
      List<Widget> dummies = generateWordPairs().take(3).map( (wp) {
        return
          new FadeTransitionWidget(
            child: new ListCard(
              text: wp.asPascalCase,
              enabled: false,
              icon: new Icon(Icons.person_outline),
            ),
            animation: placeholderAnimation,
          );
        }
      ).toList();
      return dummies;
    } else {
      return displayedFriends.length > 0 ?
        displayedFriends.map((friend) {
          return new ListCard(
            isSelected: _selectedTarget == friend,
            text: friend,
            onTap: selectTarget,
            icon: new Icon(Icons.person),
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
        _isLoading = false;
      });
      placeholderAnimationController.dispose();
    });
  }

  void onSearchChanged(String input) {
    setState(() {
      displayedFriends = _allFriends.where((friend) {
        return friend.indexOf(input) > -1;
      }).toList();
    });
  }

  void setupPlaceholderAnimation() {
     // Placeholder animation setup
    placeholderAnimationController = new AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    final CurvedAnimation curve = CurvedAnimation(
      parent: placeholderAnimationController,
      curve: Curves.linear
    );
    placeholderAnimation = Tween(begin: 1.0, end: 0.2).animate(curve);
    placeholderAnimation.addStatusListener( (status) {
      if (status == AnimationStatus.completed) {
        placeholderAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        placeholderAnimationController.forward();
      }
    });
  }
}

