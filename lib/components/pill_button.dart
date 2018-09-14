// Flutter
import 'package:flutter/material.dart';

typedef void ButtonTapped();

class PillButton extends StatelessWidget {
  final ButtonTapped onTap;
  final String text;

  PillButton({Key key, this.text, this.onTap }) : super( key: key );

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        child: Text(text, style: TextStyle(fontSize: 18.00)),
        onPressed: () => onTap(),
        color: Theme.of(context).primaryColor,
        textColor: Theme.of(context).primaryTextTheme.button.color,
        padding: EdgeInsets.symmetric(vertical: 16.00, horizontal: 32.00),
        shape: new RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              999.99), // choosing a ridiculous number makes the bordes circular
          side: BorderSide(color: Colors.transparent),
        ));
  }
}
