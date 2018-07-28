import 'package:flutter/material.dart';

import 'package:bikecouch/pages/login_page.dart';
import 'package:bikecouch/pages/register_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  final routes = <String, WidgetBuilder> {
    RegisterPage.tag: (context) => RegisterPage(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'bikecouch',
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.grey[300],
      ),
      home: new LoginPage(),
      routes: routes,
    );
  }
}
