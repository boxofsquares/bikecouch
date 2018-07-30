//dummy home page that should be replaced by Janik's

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:bikecouch/widgets/nice_button.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _handleSignOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Center(child: Text(appState.user.displayName),)
      body: Column(
        children: <Widget>[
          SizedBox(height: 100.0),
          Text('replace with user data'),
          NiceButton(
            onPress:(){
              _handleSignOut()
                .then((value) => print(value))
                .catchError((e) => print(e));
            },
            text: 'Sign Out',
          ),
          // NiceButton(
          //   onPress: ,
          // )
        ],
      )
    );
  }
}
