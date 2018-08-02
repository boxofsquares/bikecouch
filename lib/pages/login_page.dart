import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/storage.dart';
import '../models/user.dart';

import '../app_state_container.dart';
import '../models/app_state.dart';


class LoginPage extends StatefulWidget {
  LoginPage();

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  var _email;
  var _password;
  final _emailFieldController = TextEditingController();
  final _passFieldController = TextEditingController();
  bool _requiredFieldsFilled = false;
  AppState appState;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFieldController.addListener(_checkIfFilled);
    _passFieldController.addListener(_checkIfFilled);
  }

  _checkIfFilled() {
    if (_emailFieldController.text.isNotEmpty && _passFieldController.text.isNotEmpty) {
      setState(() => _requiredFieldsFilled = true);
    } else {
      setState(() => _requiredFieldsFilled = false);
    }
  }

  Future<User> _handleLogin() async {
    // setState(() => _isLoading = true);
    FirebaseUser firebaseUser = await _auth.signInWithEmailAndPassword(email: _email, password: _password);
    User user = await Storage.getUserDetails(firebaseUser);
    // setState(() => _isLoading = false);
    return user;
  }

  // _handleLoginWrapper() {
  //   setState(() => _isLoading = true);
  //   _handleLogin()
  //     .then((value) {
        
  //     })
  //     .catchError((e){
  //       print('caught error');
  //       setState(() => _isLoading = false);
  //       _makeSnackBar(e.details);
  //     });
  // }

  _makeSnackBar(String message) {
    final snackbar = SnackBar(
      content: Text(message)
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {

    var container = AppStateContainer.of(context);
    appState = container.state;

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
      controller: _emailFieldController,
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
      controller: _passFieldController,
    );

  final submit = GestureDetector(
      onTap: (){
        if (_requiredFieldsFilled) {
          // container.isLoading(true);
          setState(() => _isLoading = true);
          final form = _formKey.currentState;
          form.save();
          _handleLogin()
            .then((user) {
              container.setUser(user);
              // container.isSignedIn(true);
            })
            .catchError((e) {
              // container.isLoading(false);
              setState(() => _isLoading = false);
              _makeSnackBar(e.details);
            });
        } else {
          print('Missing required fields');
        }
      },
      child: Container(
        height: 55.0,
        decoration: BoxDecoration(
          color: _requiredFieldsFilled ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,
          borderRadius: BorderRadius.circular(7.0)
        ),
        child: Center (
          child: _isLoading ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColorLight),
          ) : Text(
            'Log In',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )
          ),
        )
      ),
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
              SizedBox(height: 60.0), //compensate for lack of logo
              Text(
                'bikecouch',
                style: TextStyle(
                  fontSize: 60.0,
                  fontWeight: FontWeight.bold,
                )
              ),
              SizedBox(height: 10.0),
              email,
              SizedBox(height: 10.0),
              password,
              SizedBox(height: 55.0),
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

