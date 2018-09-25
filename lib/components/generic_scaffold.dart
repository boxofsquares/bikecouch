// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Dart
import 'dart:io' show Platform;

// Components
import 'package:bikecouch/components/platform_widget.dart';

/*
  This is WORK IN PROGESS and does not work AT ALL

  Problems: 
    Any widgets that are associated with Material design (ListTile, Cards etc.)
    requrire a Material parent. Only GENERIC elements, such as boxes can be used 
    with a platform agnostic scaffolding like this one. :(
*/

class PlatformScaffold extends PlatformWidget {
  final Widget body;
  final Widget appbar;
  final Widget floatingActionButton;
  final FloatingActionButtonLocation floatingActionButtonLocation;

  PlatformScaffold({
    Key key, 
    this.body, 
    this.appbar, 
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    }) 
    : super( key : key );

  @override
  Scaffold buildAndroidWidget(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      body: body,
      floatingActionButton: this.floatingActionButton,
      floatingActionButtonLocation: this.floatingActionButtonLocation, 
    );
  }

  @override
  buildIOSWidget(BuildContext context) {
    Widget scaffoldBody;
    if (floatingActionButton == null) {
      scaffoldBody = this.body;
    } else {
      scaffoldBody = new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          this.body,
          Positioned(
            bottom: 0.00,
            left: 0.00,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                floatingActionButton,
              ],
            ),
          ),
        ],
      );
    }
    return CupertinoPageScaffold(
      navigationBar: appbar,
      child: scaffoldBody,
    );
  }
}