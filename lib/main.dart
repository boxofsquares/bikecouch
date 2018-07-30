import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:bikecouch/pages/login_page.dart';
import 'package:bikecouch/pages/register_page.dart';
import 'package:bikecouch/pages/home_page.dart';
import 'package:bikecouch/word_list.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  //   RegisterPage.tag: (context) => RegisterPage(),
  // };

  Widget _handleAuthFlow() {
    return new StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // some activity spinner
        } else {
          if (snapshot.hasData) {
            return HomePage(user: snapshot.data); //user: snapshot.data to pass data
          }
          return LoginPage();
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(  
      debugShowCheckedModeBanner: false,
      title: 'bikecouch',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        // primaryColor: Colors.green, //ask Janik which green he wants
        // hintColor: Colors.grey[300],
      ),
      home: _handleAuthFlow(),
      routes: {
        '/register': (context) => RegisterPage(),
      },
    );
  }
}