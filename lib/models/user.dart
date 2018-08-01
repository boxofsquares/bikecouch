import 'package:flutter/material.dart';

class User {
  User({@required this.uuid, @required this.email, @required this.name, @required this.image});

  final String uuid;
  final String email;
  final String name;
  final String image;
}

