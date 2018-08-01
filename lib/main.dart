import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/word_list.dart';

import 'models/user.dart';
import 'app_state_container.dart';
import 'models/app_state.dart';

void main() => runApp(new AppStateContainer(child: MyApp()));

class MyApp extends StatelessWidget {
  AppState appState;

  // Widget _handleAuthFlow() {
  //   return StreamBuilder<FirebaseUser>(
  //     stream: FirebaseAuth.instance.onAuthStateChanged,
  //     builder: (BuildContext context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Scaffold(); //temp splash page
  //       } else {
  //         if (snapshot.hasData) {
  //           return WordList(user: snapshot.data); //user: snapshot.data to pass data
  //         }
  //         return LoginPage();
  //       }
  //     }
  //   );
  // }

  Widget _handleAuthFlowTwo() {
    if (appState == null) {
      return Scaffold();
    } else {
      if (appState.isSignedIn) {
        return WordList();
      } else {
        return LoginPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    var container = AppStateContainer.of(context);
    appState = container.state;

    return MaterialApp(  
      debugShowCheckedModeBanner: false,
      title: 'bikecouch',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        // primaryColor: Colors.green, //ask Janik which green he wants
        hintColor: Colors.grey[300],
      ),
      home: _handleAuthFlowTwo(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}