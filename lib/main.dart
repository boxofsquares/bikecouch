import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bikecouch/pages/login_page.dart';
import 'package:bikecouch/pages/register_page.dart';
import 'package:bikecouch/pages/home_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder> {
    RegisterPage.tag: (context) => RegisterPage(),
  };

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(  
      debugShowCheckedModeBanner: false,
      title: 'bikecouch',
      theme: ThemeData(
        primaryColor: Colors.blue, //ask Janik which green he wants
        hintColor: Colors.grey[300],
      ),
      home: new LoginPage(),
      routes: routes,
    );
  }
}
