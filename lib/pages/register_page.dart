import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:bikecouch/widgets/nice_button.dart';
import 'package:bikecouch/widgets/nice_form_field.dart';

class RegisterPage extends StatefulWidget {
  static String tag = 'RegisterPage';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  _RegisterPageState createState() => new _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  
  registerAccount() {
    
  }
  
  
  @override
  Widget build(BuildContext context) {

    final email = NiceFormField(
      hintText: 'Email',
      keyboardType: TextInputType.emailAddress,
    );

    final password = NiceFormField(
      hintText: 'Password', 
      obscureText: true,
    );

    final submit = NiceButton(
      onPress: (){},
      text: 'Sign Up',
    );


    return Scaffold(
      body: Center(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          children: <Widget>[
            email,
            SizedBox(height: 10.0),
            password,
            SizedBox(height: 75.0),
            submit,
          ]
        )
      )
    );
  }
}

