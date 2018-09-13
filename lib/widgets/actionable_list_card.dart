import 'package:flutter/material.dart';

class ActionableListCard extends StatelessWidget {
  ActionableListCard({this.text, this.onPress});

  final String text;
  final onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        // color: Theme.of(context).canvasColor,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          border: Border(
              top: BorderSide(
                  width: 1.0,
                  color: Colors.grey[300],
                  style: BorderStyle.solid)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(text, style: TextStyle(fontSize: 18.0)),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[300],
            )
          ],
        ),
      ),
    );
  }
}
