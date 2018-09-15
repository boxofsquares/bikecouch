// Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRecord {
  FriendRecord({ this.uid, this.status, this.created, this.score });

  final String uid;
  final bool status;
  final DateTime created;
  final int score;

  factory FriendRecord.fromDocument(DocumentSnapshot ds) {
    return FriendRecord(
      uid: ds.documentID,
      status: ds.data['status'],
      created: ds.data['created'],
      score: ds.data['score'],
    );
  }

  Object toObject() {
    return {
      'status': status,
      'created': created, 
      'score': score,
    };
  }
}