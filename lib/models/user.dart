import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({@required this.uuid, @required this.email, @required this.name, @required this.image, @required this.points, @required this.tokens});

  final String uuid;
  final String email;
  final String name;
  final String image;
  final int points;
  final int tokens;

  factory User.fromDocument(DocumentSnapshot ds) {
    return new User(
      uuid: ds.documentID,
      name: ds.data["displayName"],
      email: ds.data['email'],
      image: ds.data['image'],
      points: ds.data['points'],
      tokens: ds.data['tokens'],
    );
  }
}

