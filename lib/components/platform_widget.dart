// Flutter
import 'package:flutter/material.dart';

// Dart
import 'dart:io' show Platform;


abstract class PlatformWidget<I extends Widget, A extends Widget> extends StatelessWidget {
Key key;

PlatformWidget({this.key}) : super(key : key);

@override
Widget build(BuildContext context){
    if (Platform.isAndroid) {
      buildAndroidWidget(context);
    } else if (Platform.isIOS) {
      buildIOSWidget(context);
    } else {
      return new Container();
    }
  }

  I buildAndroidWidget(BuildContext context);

  A buildIOSWidget(BuildContext context);
}