import 'package:flutter/material.dart';
import 'package:bikecouch/word_list.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'BikeCouch App',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new WordList(), // jump straight into word selection screen for now
    );
  }
}
