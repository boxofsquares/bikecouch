// Flutter
import 'package:flutter/material.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';

// Dart
import 'dart:async';

// Utils
import 'package:bikecouch/utils/storage.dart';

// Models
import 'package:bikecouch/models/app_state.dart';
import 'package:bikecouch/models/user.dart';
import 'package:bikecouch/app_state_container.dart';


class RegisterPage extends StatefulWidget {
  static String tag = 'RegisterPage';

  @override
  _RegisterPageState createState() => new _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  AppState appState;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  
  String _email;
  String _password;
  String _name;
  bool _isLoading = false;
  final _emailFieldController = TextEditingController();
  final _passFieldController = TextEditingController();
  final _nameFieldController = TextEditingController();
  bool _requiredFieldsFilled = false;

  @override
  void initState() {
    super.initState();
    _emailFieldController.addListener(_checkIfFilled);
    _passFieldController.addListener(_checkIfFilled);
    _nameFieldController.addListener(_checkIfFilled);
  }

  _checkIfFilled() {
    if (_emailFieldController.text.isNotEmpty && _passFieldController.text.isNotEmpty && _nameFieldController.text.isNotEmpty) {
      setState(() => _requiredFieldsFilled = true);
    } else {
      setState(() => _requiredFieldsFilled = false);
    }
  }

  Future<User> _handleRegister() async {
    // setState(() => _isLoading = true);
    FirebaseUser user = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
    Storage.registerUserDetails(user.uid, _name);
    User userDetails = User(uuid: user.uid, email: user.email, name: _name, image: '');
    // setState(() => _isLoading = false);
    return userDetails;
  }

  //   FirebaseUser _handleRegisterWrapper() {
  //   FirebaseUser user;
  //   setState(() => _isLoading = true);
  //   _handleRegister()
  //     .then((v) {
  //       Navigator.pop(context);
  //     }) 
  //     .catchError((e){
  //       print('caught error');
  //       setState(() => _isLoading = false);
  //       _makeSnackBar(e.details);
  //     });
  //   return user;
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
      validator: (value) {},
      onSaved: (val) => _email = val,
      controller: _emailFieldController,
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
      controller: _passFieldController,
    );

    final name = TextFormField(
      autocorrect: false,
      decoration: InputDecoration(
        hintText: 'Name',
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0)
        )
      ),
      validator: (value) {},
      onSaved: (val) => _name = val,
      controller: _nameFieldController,
    );
    
    // NiceFormField(
    //   hintText: 'Password', 
    //   obscureText: true,
    // );

    final submit = GestureDetector(
      onTap: (){
        if (_requiredFieldsFilled) {
          final form = _formKey.currentState;
          if (form.validate()) {
            setState(() => _isLoading = true);
            form.save();
            // _handleRegisterWrapper();
            _handleRegister()
              .then((userDetails) {
                container.setUser(userDetails);
                // container.isSignedIn(true);
                Navigator.pop(context);
              })
              .catchError((e) {
                setState(() => _isLoading = false);
                _makeSnackBar(e.details);
              });
          }
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
          child: _isLoading 
          ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColorLight),
          ) 
          : Text(
            'Sign Up',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )
          ),
        )
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        elevation: 0.0,
      ),
      key: _scaffoldKey,
      body: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 30.0),
              email,
              SizedBox(height: 10.0),
              password,
              SizedBox(height: 10.0),
              name,
              SizedBox(height: 55.0),
              submit,
            ]
          )
        )
      )
    );
  }
}

