import 'package:flutter/material.dart';
import 'package:bikecouch/pages/register_page.dart';
import 'package:bikecouch/widgets/nice_button.dart';
import 'package:bikecouch/widgets/nice_form_field.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
      text: 'Login',
    );

    final signup = Center(
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).pushNamed(RegisterPage.tag);
        },
        child: Text(
          'Sign Up',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        )
      )
    );

    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          children: <Widget>[
            email,
            SizedBox(height: 10.0),
            password,
            SizedBox(height: 75.0),
            submit,
            SizedBox(height: 20.0),
            signup,
          ]
        )
      )
    );
  }
}

