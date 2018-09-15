// Flutter
import 'package:flutter/material.dart';

class NiceButton extends StatelessWidget {
  NiceButton({@required this.text, @required this.onPress});
  
  final text;
  final onPress;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: 55.0,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(7.0)
        ),
        child: Center (
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )
          )
        ),
      ),
    );
  }
}
