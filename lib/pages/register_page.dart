import 'package:flutter/material.dart';
import 'dart:async';

import 'package:bikecouch/widgets/nice_button.dart';
import 'package:firebase_auth/firebase_auth.dart';



class RegisterPage extends StatefulWidget {
  static String tag = 'RegisterPage';

  @override
  _RegisterPageState createState() => new _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  
  String _email;
  String _password;

  Future<FirebaseUser> _handleRegister() async {
    FirebaseUser user = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
    return user;
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
      validator: (value) {
        
      },
      onSaved: (val) => _email = val,
    );

    // NiceFormField(
    //   hintText: 'Email',
    //   keyboardType: TextInputType.emailAddress,
    // );

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
      validator: (value) {
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
      },
      onSaved: (val) => _password = val,
    );
    
    // NiceFormField(
    //   hintText: 'Password', 
    //   obscureText: true,
    // );

    final submit = GestureDetector(
      onTap: (){
        final form = _formKey.currentState;
        if (form.validate()) {
          form.save();
          _handleRegister()
            .then((value) => print(value))
            .catchError((e) => _makeSnackBar(e.details)
          );
        }
      },
      child: Container(
        height: 55.0,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(7.0)
        ),
        child: Center (
          child: Text(
            'Sign Up',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )
          )
        ),
      ),
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
            ]
          )
        )
      )
    );
  }
}

