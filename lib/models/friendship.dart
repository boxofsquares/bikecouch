// Flutter
import 'package:flutter/material.dart';

// Models
import 'package:bikecouch/models/user.dart';


enum FriendshipStatus { 
  Pending,
  Friends,
  Strangers
}
class Friendship {
  final User friend;
  FriendshipStatus friendshipStatus;

  Friendship({@required this.friend, this.friendshipStatus}); 
}