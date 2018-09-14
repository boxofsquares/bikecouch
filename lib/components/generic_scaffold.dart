// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Dart
import 'dart:io' show Platform;

/*
  This is WORK IN PROGESS and does not work AT ALL

  Problems: 
    Any widgets that are associated with Material design (ListTile, Cards etc.)
    requrire a Material parent. Only GENERIC elements, such as boxes can be used 
    with a platform agnostic scaffolding like this one. :(
*/

class GenericScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget> appBarWidgets;
  final String appBarText;
  final Widget floatingActionButton;
  final FloatingActionButtonLocation floatingActionButtonLocation;

  GenericScaffold({
    Key key, 
    this.body, 
    this.appBarText, 
    this.appBarWidgets, 
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    }) 
    : super( key : key);

  Widget build(BuildContext context) {
  if (Platform.isAndroid) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(appBarText),
        actions: this.appBarWidgets,
      ),
      body: this.body,
      floatingActionButton: this.floatingActionButton,
      floatingActionButtonLocation: this.floatingActionButtonLocation,
    );
  } else {
    return CupertinoPageScaffold(
      navigationBar: new CupertinoNavigationBar(
        middle: new Text(appBarText),
      ),
      child: body,
    );
  }
  }
}