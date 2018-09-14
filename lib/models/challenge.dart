// Models
import 'package:bikecouch/models/friend.dart';

class Challenge {
  final String uid;
  final Friend challenger;
  final List<String> wordPair;
  
  Challenge({this.uid, this.challenger, this.wordPair});
}