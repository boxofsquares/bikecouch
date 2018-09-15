// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';

// 3rd Party
import 'package:english_words/english_words.dart';

// Pages
import 'package:camera/camera.dart';
import 'package:bikecouch/pages/target_list.dart';
import 'package:bikecouch/pages/camera_page.dart'; //adding page because want to navigate by passing variable and don't know how to do that with route

// Utils
import 'package:bikecouch/utils/storage.dart';

// Models
import 'package:bikecouch/models/app_state.dart';
import 'package:bikecouch/app_state_container.dart';
import 'package:bikecouch/models/challenge.dart';

// UI Components
import 'package:bikecouch/components/pill_button.dart';
import 'package:bikecouch/components/list_card.dart';
import 'package:bikecouch/components/fade_animation_widget.dart';


// const WORD_SOURCE = 0; // use for english nouns
const WORD_SOURCE = 1; // use for DataMuse API

class WordList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WordListState();
  }
}

/*
  Screen that lets the user choose from two a list of 10 words.
*/
class _WordListState extends State<WordList>
    with SingleTickerProviderStateMixin {
  AppState appState;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> _selectedWords;
  List<String> _allWords;
  bool _isLoading;
  bool _isOffline;
  int _currentTabIndex;
  var num;

  Animation<double> placeholderAnimation;
  AnimationController placeholderAnimationController;

  @override
  void initState() {
    _selectedWords = List<String>();
    _allWords = List<String>();
    _isOffline = false;
    _isLoading = false;
    _currentTabIndex = 0;
    _setupPlaceholderAnimation();
    _shuffleWords();
    super.initState();
  }

  @override
  void dispose() {
    placeholderAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var container = AppStateContainer.of(context);
    appState = container.state;

    Widget newChallenge = new ListView(
      children: createWordSuggestions(),
      padding: EdgeInsetsDirectional.only(bottom: 60.00),
    );

    // Widget pendingChallenges = new ListView(
    //   children: buildPendingChallenges(),
    // );

    Widget pendingChallenges = _buildPendingChallenges();

    return Scaffold(
      appBar: new AppBar(
        title: new Text('${appState.user.name}'), //${appState.user.name}
        // title: new Text('Test'), //${appState.user.name}

        leading: IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _auth.signOut();
              container.setUser(null);
              // container.isSignedIn(false);
            }),
        actions: <Widget>[
          IconButton(
            icon: _currentTabIndex == 0
                ? Icon(Icons.shuffle)
                : Icon(Icons.refresh),
            onPressed: _currentTabIndex == 0 ? _shuffleWords : () => {},
          ),
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () => Navigator.pushNamed(context, '/add_friends'),
          )
        ],
        elevation: 0.0,
      ),
      body: _currentTabIndex == 0 ? newChallenge : pendingChallenges,
      floatingActionButton: _currentTabIndex == 0 && _selectedWords.length >= 2
          ? PillButton(
              text: "Choose your target!",
              onTap: _setChallenge,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered),
            title: Text('New Challenge'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            title: Text('Your Challenges'),
          )
        ],
        onTap: (int index) => _handleNavigationBarTab(index),
        currentIndex: _currentTabIndex,
      ),
    );
  }

  List<Widget> createWordSuggestions() {
    if (!_isOffline) {
      return _allWords.map((String word) {
        final isSelected = _selectedWords.contains(word);
        ListCard w = new ListCard(
          onTap: () => _chooseWord(word),
          isSelected: isSelected,
          text: word,
          enabled: !_isLoading,
        );
        return _isLoading
            ? new FadeTransitionWidget(
                animation: placeholderAnimation,
                child: w,
              )
            : w;
      }).toList();
    } else {
      return <Widget>[
        new ListCard(
          enabled: false,
          text: "Please check your internet connection.",
        ),
      ];
    }
  }

  void _chooseWord(word) {
    setState(() {
      final indexFound = _selectedWords.indexOf(word);
      if (indexFound > -1) {
        _selectedWords.removeAt(indexFound);
      } else {
        _selectedWords.add(word);
        _selectedWords.length > 2 ? _selectedWords.removeAt(0) : null;
      }
    });
  }

  void _setChallenge() {
    Navigator
        .of(context)
        .push(new MaterialPageRoute(
          builder: (context) => new TargetList(
                challenge: _selectedWords,
              ),
        ))
        .then((reset) {
      if (reset == null) {
        return;
      } else if (reset == true) {
        _shuffleWords();
      }
    });
  }

  void _shuffleWords() async {
    placeholderAnimationController.forward();
    _isLoading = true;
    // DataMuse.datamuseFetchData().then((res) {
    //   var dmWordList = res.words.where((word) {
    //     return word.tags.length < 2 && word.tags.contains("n");
    //   }).map((word) {
    //     return word.word;
    //   }).toList();
    //   _allWords.clear();
    //   setState(() {
    //     for (var i = 0; i < 10; i++) {
    //       var index = num.nextInt(dmWordList.length);
    //       _allWords.add(dmWordList[index]);
    //     }
    //     _isLoading = false;
    //     _isOffline = false;
    //   });
    //   placeholderAnimationController.reset();
    // }).catchError((e) {
    //   setState(() {
    //     _isLoading = false;
    //     _isOffline = true;
    //   });
    // });

    // num = Random(new DateTime.now().millisecondsSinceEpoch);
    List<String> _newWords = await Storage.getRandomWords('kitchen');
    setState(() {
      _isLoading = false;
      _isOffline = false;
      _selectedWords.clear();
      // _allWords.clear();
      _allWords = _newWords;

      // for (var i = 0; i < 10; i++) {
      //   var index = num.nextInt(nouns.length);
      //   _allWords.add(nouns[index]);
      // }
    });
    placeholderAnimationController.reset();
  }

  void _setupPlaceholderAnimation() {
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

  void _launchCamera(Challenge challenge) {
    availableCameras().then((cameras) async {
      print(cameras);
      int returningPageIndex = await Navigator.of(context).push(new MaterialPageRoute(
            builder: (context) => CameraPage(
              cameras: cameras,
              challenge: challenge,
              ),
          ));
      _currentTabIndex = returningPageIndex ?? _currentTabIndex;
    }).catchError((e) => print('camera error'));
  }

  Widget _buildPendingChallenges() {
    return StreamBuilder(
        stream: Storage.pendingChallengesStreamFor(appState.user.uuid),
        builder: (BuildContext context,
            AsyncSnapshot<List<Challenge>> asyncSnapshot) {
          List<Widget> listItems;
          if (asyncSnapshot.hasData) {
            if (placeholderAnimationController.isAnimating) {
              placeholderAnimationController.reset();
            }
            if (asyncSnapshot.data.length == 0) {
              listItems = <Widget>[
                new ListTile(
                  title: Text(
                    'No pending challenges :(',
                    style: TextStyle(color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                  contentPadding: EdgeInsets.all(18.00),
                )
              ];
            } else {
              listItems = asyncSnapshot.data.map((challenge) {
                return ListCard(
                  text: challenge.wordPair.join('  '),
                  enabled: true,
                  leadingIcon: Icon(Icons.send),
                  trailingIcon: Text(challenge.challenger.name),
                  onTap: () => _launchCamera(
                    challenge,
                    ),
                );
              }).toList();
            }
          } else {
            //NOTE: LOADING
            listItems = generateWordPairs().take(3).map((wp) {
              return new FadeTransitionWidget(
                child: new ListCard(
                  text: wp.asPascalCase,
                  enabled: false,
                  leadingIcon: Icon(Icons.send),
                  ),
                  animation: placeholderAnimation,
              );
            }).toList();
            placeholderAnimationController.forward();
          }
          return new ListView(
            children: listItems,
          );
        });
  }

  void _handleNavigationBarTab(int index) {
    setState(() {
      switch (index) {
        case 0:
          // TODO: Something to do here..
          break;
        case 1:
          //TODO: Somethine else to do here...

          break;
      }
      _currentTabIndex = index;
    });
  }
}
