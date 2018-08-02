import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';
import '../models/friendship.dart';
import '../models/invitation.dart';
import '../models/challenge.dart';

class Storage {
  static final Firestore _store = Firestore.instance;

  static Future<bool> registerUserDetails(String userUID, String displayName){
    _store.collection('userDetails').document(userUID).setData({
      'displayName': displayName,
    });
    // for now, return true
    return Future.value(true);
  }

  static Future<List<String>> getFriendsAsUID(String userUID) async {
    QuerySnapshot q = await _store
                              .collection('friends')
                              .where('uuid', isEqualTo: userUID)
                              .getDocuments();
    // extract uids for all friends
    return q.documents.map( (doc) { return doc['fuid']; }).cast<String>().toList();;
  }

  static Future<List<User>> getFriendsAsUsers(String userUID) async {
    // collect all friends uids
    List<String> fuids = await getFriendsAsUID(userUID);
    
    // make a list of all query futures
    List<Future<User>> futures = 
      fuids
        .map( (fuid) async {
          DocumentSnapshot ds = await _store
                    .collection('userDetails')
                    .document(fuid)
                    .get();
          return User.fromDocument(ds);
        }).toList();

    // wait for all query futures to be resolved
    return await Future.wait(futures);            
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
        'inviter': inviterUID,
        'invitee': inviteeUID,
      });
    // for now, always return true
    return Future.value(true);
  }


  /*
    Accept friend request
  */
  static Future<bool> acceptFriendRequest(String invitationUID) async {

    DocumentSnapshot ds = await _store
      .collection('friendInvitation')
      .document(invitationUID)
      .get();

    _store
      .collection('friends')
      .document()
      .setData({
        'uuid': ds.data['invitee'],
        'fuid': ds.data['inviter'],
      });

    _store
      .collection('friends')
      .document()
      .setData({
        'uuid': ds.data['inviter'],
        'fuid': ds.data['invitee'],
      });

    _store
      .collection('friendInvitation')
      .document(invitationUID)
      .delete();
    
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

    // TODO: sean please delete this soon, just for debugging
    if (d.data == null) {
      print('THIS SHOULD NEVER HAPPEN!!!!!!!!!!!!!!!!!!!!!!!!!!');
      return User(uuid: '', email: '', image: '', name: 'MISTAKE');
    }
    return User(uuid: firebaseUser.uid, email: firebaseUser.email, image: '', name: d['displayName']);
  }

  /*
    Get all users with displayName matching keyWord (prefix only!).
  */
  static Future<List<User>> getUsersByDisplayNameWith(String keyWord) async{
    QuerySnapshot q = await _store
      .collection('userDetails')
      .where('displayName', isEqualTo: keyWord,)
      .getDocuments();
    return q.documents.map( (ds) { 
      return User.fromDocument(ds);
    }).toList();
  }

  static Future<List<Friendship>> getFriendShipsByDisplayNameWith(String keyWord, String userUID) async {
    List<User> users = await getUsersByDisplayNameWith(keyWord);
    List<Future<Friendship>> fs = users.map( (user) async {
      QuerySnapshot qs = await _store
        .collection('friendInvitation')
        .where('inviter', isEqualTo: userUID)
        .where('invitee', isEqualTo: user.uuid)
        .getDocuments();
      FriendshipStatus status;
      if (qs.documentChanges.length > 0) {
        status = FriendshipStatus.Pending;
      } else {
        status = FriendshipStatus.Strangers;
      }
      return new Friendship(friend: user, friendshipStatus: status);
    }).toList();
    return await Future.wait(fs);
  } 
 

  /*
    Get all pending friend requests.
  */
  static Future<List<Invitation>> getPendingFriendRequests(String uuid) async {
    QuerySnapshot q = await _store
      .collection('friendInvitation')
      .where('invitee', isEqualTo: uuid)
      .getDocuments();
    
    List<Future<Invitation>> futures = q.documents.map((document) async {
      DocumentSnapshot ds = await _store
        .collection('userDetails')
        .document(document['inviter'])
        .get();
        
        return Invitation(
          user: User.fromDocument(ds), 
          invitationUID: document.documentID
        );
    }).toList();

    return await Future.wait(futures); 
  }

  static Future<List<Challenge>> getPendingChallengesFor(String userUID) async {
    QuerySnapshot q = await _store
      .collection('challenges')
      .where('target', isEqualTo: userUID)
      .getDocuments();
    
    List<Future<Challenge>> futures = q.documents.map((doc) async { 
      Set<String> set = new Set<String>();
      set.add(doc.data['wordpair'][0]);
      set.add(doc.data['wordpair'][1]);

      DocumentSnapshot ds = await _store
        .collection('userDetails')
        .document(doc.data['challenger'])
        .get();

      User challenger = User.fromDocument(ds);

      return new Challenge(
        uid: doc.documentID,
        challenger: challenger,
        wordPair: set,
      );
    }).toList(); 

    return await Future.wait(futures);
  }

  static Future<bool> sendChallengeFromTo(String userUID, String targetUID, List<String> wordPair) {
    _store
      .collection('challenges')
      .document()
      .setData({
        'challenger': userUID,
        'target': targetUID,
        'wordpair': wordPair.toList(),
      });
    return Future.value(true);
  }
}
