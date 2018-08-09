import 'package:flutter/material.dart';

//callback typedefs
typedef void CardTapped();

/*
  A card that contains one ListTile
*/
class ListCard extends StatelessWidget {
  final String text;
  final CardTapped onTap;
  final bool enabled;
  final bool isSelected;
  final Widget leadingIcon;
  final Widget trailingIcon;

  ListCard({
    Key key,
    @required this.text,
    this.onTap,
    this.isSelected = false,
    this.enabled = true,
    this.leadingIcon,
    this.trailingIcon,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: isSelected ? 24.00 : 18.00),
        textAlign: leadingIcon == null ? TextAlign.center : TextAlign.left,
      ),
      onTap: onTap,
      selected: isSelected,
      contentPadding: EdgeInsets.symmetric(vertical: 16.00, horizontal: 32.00),
      enabled: enabled,
      leading: leadingIcon,
      trailing: trailingIcon,
    );
  }
}
