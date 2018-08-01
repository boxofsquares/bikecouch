import 'package:flutter/material.dart';

import 'user.dart';


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