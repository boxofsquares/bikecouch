import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:bikecouch/widgets/nice_button.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  var _email;
  var _password;

  Future<FirebaseUser> _handleLogin() async {
    return await _auth.signInWithEmailAndPassword(email: _email, password: _password);
  }

  _makeSnackBar(String message) {
    final snackbar = SnackBar(
      content: Text(message)
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {

    final email = TextFormField(
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'Email',
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0)
        )
      ),
      onSaved: (val) => _email = val,
    );

    final password = TextFormField(
      autocorrect: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0)
        )
      ),
      onSaved: (val) => _password = val,
    );

    final submit = NiceButton(
      onPress: (){
        final form = _formKey.currentState;
        form.save();
        _handleLogin()
          .then((FirebaseUser user) => print(user))
          .catchError((e) => _makeSnackBar(e.details));
      },
      text: 'Login',
    );

    final signup = Center(
      child: GestureDetector(
        onTap: (){
          Navigator.pushNamed(context, '/register');
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
      key: _scaffoldKey,
      body: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 100.0), //compensate for lack of logo
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
      )
    );
  }
}

