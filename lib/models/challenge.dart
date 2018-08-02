import 'user.dart';

class Challenge {
  final String uid;
  final User challenger;
  final Set<String> wordPair;
  
  Challenge({this.uid, this.challenger, this.wordPair});
}