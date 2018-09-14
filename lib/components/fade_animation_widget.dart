// Flutter
import 'package:flutter/material.dart';

class FadeTransitionWidget extends StatelessWidget {
  FadeTransitionWidget({this.child, this.animation});

  final Widget child;
  final Animation<double> animation;

  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
          return new Opacity(
            opacity: animation.value,
            child: child,
          );
      },
      child: child,
    );
  }
}