import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

// Custom Packages
import 'components/list_card.dart';
import 'datamuse.dart' as DataMuse;
import 'target_list.dart';
import 'components/pill_button.dart';

// const WORD_SOURCE = 0; // use for english nouns
const WORD_SOURCE = 1; // use for DataMuse API

class WordList extends StatefulWidget {
  WordList({Key key, this.user}) : super(key: key);
  final FirebaseUser user;


  @override
  State<StatefulWidget> createState() {
    return _WordListState();
  }
}

/*
  Screen that lets the user choose from two a list of 10 words.
*/
class _WordListState extends State<WordList> {
  List<String> _selectedWords = List<String>();
  List<String> _allWords = List<String>();
  var num;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  void initState() {
    shuffleWords();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('${widget.user.email}'),
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () { 
            _auth.signOut();
            Navigator.pushNamed(context, '/login');
          }
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shuffle),
            onPressed: shuffleWords,
          )
        ],
        elevation: 0.0,
      ),
      body: new ListView(
        children: createWordRows(),
        padding: EdgeInsetsDirectional.only(bottom: 60.00),
      ),
      floatingActionButton: _selectedWords.length >= 2
          ? PillButton(
            text: "Choose your target!",
            onTap: setChallenge,
          )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  List<ListCard> createWordRows() {
    return _allWords.map((String word) {
      final isSelected = _selectedWords.contains(word);
      return ListCard(
        onTap: _chooseWord,
        isSelected: isSelected,
        text: word,
      );
    }).toList();
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

  void setChallenge() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) => new TargetList(
          challenge: _selectedWords,
        ),
      )
    );
  }

  void shuffleWords() async {
    List<String> wordList;

    if (WORD_SOURCE == 0) {
      wordList = nouns;
    } else {
      DataMuse.DataMuseResponse res = await DataMuse.datamuseFetchData();
      wordList = res.words.where((word) {
        return word.tags.length < 2 && word.tags.contains("n");
      })
      .map((word) {
        return word.word;
      }).toList();
    }

    num = Random(new DateTime.now().millisecondsSinceEpoch);

    setState(() {
      _selectedWords.clear();
      _allWords.clear();

      for (var i = 0; i < 10; i++) {
        var index = num.nextInt(wordList.length);
        _allWords.add(wordList[index]);
      }
    });
  }
}
