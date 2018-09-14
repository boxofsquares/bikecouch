// Flutter
import 'package:flutter/material.dart';

// Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

// Models
import 'package:bikecouch/models/user.dart';


class Friend extends User {
  Friend({@required uuid, @required email, @required name, @required image, this.score}) 
  : super(uuid: uuid, email: email, name: name, image: image);
  int score;
  //TODO: Future friend attributes can go here;
  // suggetions: streak

  factory Friend.fromDocument(DocumentSnapshot ds) {
    return new Friend(
      uuid: ds.documentID,
      name: ds.data["displayName"],
      email: ds.data['email'],
      image: ds.data['image'],
    );
  }
}