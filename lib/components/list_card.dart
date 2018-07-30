import 'package:flutter/material.dart';

//callback typedefs
typedef void CardTapped(String text);

/*
  A card that contains one ListTile
*/
class ListCard extends StatelessWidget {
  final String text;
  final CardTapped onTap;
  final bool isSelected;

  ListCard({
    Key key,
    this.text,
    this.onTap,
    this.isSelected,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: isSelected ? 24.00 : 18.00),
        textAlign: TextAlign.center,
      ),
      onTap: () => onTap(text),
      selected: isSelected,
      contentPadding: EdgeInsets.all(16.00),
    );
  }
}
