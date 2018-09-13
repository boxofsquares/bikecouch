import 'package:flutter/material.dart';

class RowListCard extends StatelessWidget {
  RowListCard({this.leftText, this.rightText});

  final String leftText;
  final String rightText;


  @override
  Widget build(BuildContext context) {
    return Container (
      // color: Theme.of(context).canvasColor,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        border: Border(top: BorderSide(width: 1.0, color: Colors.grey[300], style: BorderStyle.solid)),
      ),
      child: Row(
        children: [
          Container(
            width: 100.0,
            child: Text(
              leftText,
              style: TextStyle(
                // fontWeight: FontWeight.bold
                fontSize: 18.0
              )

            ),
          ),
          
          Text(
            rightText,
            style: TextStyle(
                // fontWeight: FontWeight.bold
                fontSize: 18.0
              )
          )

        ]
      )
    );
  }
}