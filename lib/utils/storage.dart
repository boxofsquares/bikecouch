import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';


class Storage {
  static final Firestore _store = Firestore.instance;

  static Future<bool> registerUserDetails(String userUID, String displayName){
    _store.collection('userDetails').document(userUID).setData({
      'displayName': displayName,
    });
    // for now, return true
    return Future.value(true);
  }

  static Future<List<String>> getFriendsByUID(String userUID) async {
    QuerySnapshot q = await _store
                              .collection('friends')
                              .where('uuid', isEqualTo: userUID)
                              .getDocuments();
    // extract uids for all friends
    return q.documents.map( (doc) { return doc['fuid']; }).cast<String>().toList();;
  }

  static Future<List<String>> getFriendsByDisplayName(String userUID) async {
    // collect all friends uids
    List<String> fuids = await getFriendsByUID(userUID);
    
    // make a list of all query futures
    List<Future<DocumentSnapshot>> futures = 
      fuids
        .map( (fuid) {
          return _store
                    .collection('userDetails')
                    .document(fuid)
                    .get();
        }).toList();

    // wait for all query futures to be resolved
    List<DocumentSnapshot> ds = await Future.wait(futures);

    // extract the dispayName for each user
    return ds.map( (q) {
      // NOTE: This might crash was not signed up properly 
      // - a.k.a. no userDetails entry
      return q['displayName'];
    }).cast<String>().toList();             
  }

  /*
    Adding a friend-relationship between inviter and invitee.
    Double-storing for O(n) look-up time.
  */
  static Future<bool> addFriend(String inviterUID, String inviteeUID) {
    _store
      .collection('friends')
      .document()
      .setData({
        'uuid': inviterUID,
        'fuid': inviteeUID,
      });
    _store
      .collection('friends')
      .document()
      .setData({
        'uuid': inviteeUID,
        'fuid': inviterUID,
      });
    // for now, always return true
    return Future.value(true);    
  }

  /*
    Filing a friend invitation request initiated by inviter to invitee.
  */
  static Future<bool> sendFriendInvitation(String inviterUID, inviteeUID) {
    _store
      .collection('friendInvitation')
      .document()
      .setData({
        'inviter': inviteeUID,
        'invitee': inviteeUID,
      });
    // for now, always return true
    return Future.value(true);
  }

  /*
    Get user details on with given uuid.
  */
  static Future<User> getUserDetails(FirebaseUser firebaseUser) async {
    DocumentSnapshot d = await _store
      .collection('userDetails')
      .document(firebaseUser.uid)
      .get();
    
    print('email: ${firebaseUser.email}, image: ${d['image']}, name: ${d['displayName']}');
    return User(uuid: firebaseUser.uid, email: firebaseUser.email, image: d['image'], name: d['displayName']);
  }
  
  /*
    Get all users with displayName matching keyWord (prefix only!).
  */
  static Future<List<String>> getUsersByDisplayNameWith(String keyWord) async{
    QuerySnapshot q = await _store
      .collection('userDetails')
      .where('displayName', isEqualTo: keyWord,)
      .getDocuments();
    return q.documents.map( (doc) { return doc['displayName']; }).cast<String>().toList();;
  }  
}