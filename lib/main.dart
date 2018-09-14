import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Pages
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/word_list.dart';
import 'pages/add_friends_page.dart';
import 'pages/profile_page.dart';

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
    // if (appState == null || appState.isSignedIn == null) {
    //   return Scaffold(
    //     appBar: AppBar(elevation: 0.0,),
    //   );
    // } else {
    //   if (appState.user != null) {
    //     return WordList();
    //   } else {
    //     return LoginPage();
    //   }
    // }
    if (appState.isLoading) {
      // temp splash page
      return Scaffold(
        appBar: AppBar(elevation: 0.0),
        body: Center(
          // child: CircularProgressIndicator(),
          child: new Container(),
        ),
      );
    } else if (!appState.isLoading && appState.user == null) {
      return LoginPage();
    } else {
      return WordList();
      // return TestCamera();
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
        primarySwatch: Colors.pink,
        // primaryColor: Colors.green, //ask Janik which green he wants
        hintColor: Colors.grey[300],
      ),
      home: _handleAuthFlowTwo(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/add_friends': (context) => AddFriendsPage(),
        '/word_list': (context) => WordList(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}