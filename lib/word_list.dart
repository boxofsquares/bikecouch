import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'dart:math';

class WordList extends StatefulWidget {
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

  @override
  void initState() {
    shuffleWords();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Pick The Challenge!'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shuffle),
            onPressed: shuffleWords,
          )
        ],
      ),
      body: new ListView(
        children: createWordRows(),
      ),
      floatingActionButton: RaisedButton(
        child: Text("Choose your target!", style: TextStyle(fontSize: 18.00)),
        onPressed: _selectedWords.length >= 2 ? setChallenge : null,
        color: Colors.green,
        textColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16.00, horizontal: 32.00),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  List<ListTile> createWordRows() {
    return _allWords.map((String word) {
      var sel = _selectedWords.contains(word);
      return ListTile(
        title: Text(
          word,
          textAlign: sel ? TextAlign.right : TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.00),
        ),
        onTap: () => _chooseWord(word),
        selected: sel,
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
    // TODO: Send the 2 words to the next screen.
  }

  void shuffleWords() {
    num = Random(new DateTime.now().millisecondsSinceEpoch);
    setState(() {
      _selectedWords.clear();
      _allWords.clear();
      for (var i = 0; i < 10; i++) {
        var index = num.nextInt(nouns.length);
        _allWords.add(nouns[index]);
      }
    });
  }
}
