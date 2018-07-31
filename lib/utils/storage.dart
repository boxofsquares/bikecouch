import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';


class Storage {
  static final Firestore _store = Firestore.instance;

  static Future<bool> registerUserDetails(String userUID, String displayName){
    _store.collection('userDetails').document().setData({
      'displayName': displayName,
      'uuid': userUID,
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
    List<Future<QuerySnapshot>> futures = 
      fuids
        .map( (fuid) {
          return _store
                    .collection('userDetails')
                    .where('uuid', isEqualTo: fuid)
                    .getDocuments();
        }).toList();

    // wait for all query futures to be resolved
    List<QuerySnapshot> qs = await Future.wait(futures);

    // extract the dispayName for each user
    return qs.map( (q) {
      // NOTE: This might crash was not signed up properly 
      // - a.k.a. no userDetails entry
      return q.documents.first['displayName'];
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
}