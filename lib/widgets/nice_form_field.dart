import 'package:flutter/material.dart';

class NiceFormField extends StatelessWidget {
  NiceFormField({@required this.hintText, this.keyboardType = TextInputType.emailAddress, this.obscureText = false});
  
  final hintText;
  final keyboardType;
  final obscureText;
  
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autocorrect: false,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0)
        )
      )
    );
  }
}
