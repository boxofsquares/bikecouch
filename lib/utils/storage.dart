// Dart
import 'dart:async';

// Firestore/base
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Models
import 'package:bikecouch/models/user.dart';
import 'package:bikecouch/models/friend.dart';
import 'package:bikecouch/models/friendship.dart';
import 'package:bikecouch/models/invitation.dart';
import 'package:bikecouch/models/challenge.dart';
import 'package:bikecouch/models/friendRecord.dart';

class Storage {
  static final Firestore _store = Firestore.instance;

  // WORDS

  static Future<List<String>> getRandomWords(String category) async {
    return await _store
        .collection('category')
        .document(category)
        .collection('words')
        .getDocuments()
        .then((querySnap) {
      return querySnap.documents.map((doc) {
        return doc.documentID;
      }).toList();
    });
  }

  // USERS

  static Future<bool> registerUserDetails(String userUID, String displayName) {
    _store.collection('userDetails').document(userUID).setData({
      'displayName': displayName,
    });
    // for now, return true
    return Future.value(true);
  }

  static Future<List<String>> getFriendsAsUID(String userUID) async {
    QuerySnapshot q = await _store
        .collection('friends')
        .document(userUID)
        .collection('friendRecords')
        .getDocuments();
    // extract uids for all friends
    return q.documents
        .map((doc) {
          return doc.documentID;
        })
        .cast<String>()
        .toList();
  }

  static Future<List<User>> getFriendsAsUsers(String userUID) async {
    // collect all friends uids
    List<String> fuids = await getFriendsAsUID(userUID);

    // make a list of all query futures
    List<Future<User>> futures = fuids.map((fuid) async {
      DocumentSnapshot ds =
          await _store.collection('userDetails').document(fuid).get();
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
        .document(inviterUID)
        .collection('friendRecords')
        .document(inviteeUID)
        .setData({
      'status': true,
      'created': DateTime.now().toUtc(),
      'score': 0
    });

    _store
        .collection('friends')
        .document(inviteeUID)
        .collection('friendRecords')
        .document(inviterUID)
        .setData({
      'status': true,
      'created': DateTime.now().toUtc(),
      'score': 0,
    });

    // for now, always return true
    return Future.value(true);
  }

  /*
    Filing a friend invitation request initiated by inviter to invitee.
  */
  static Future<bool> sendFriendInvitation(String inviterUID, inviteeUID) {
    _store.collection('friendInvitation').document().setData({
      'inviter': inviterUID,
      'invitee': inviteeUID,
      //TODO: Server-side time stamp would be better.
      'created': DateTime.now().toUtc(),
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

    addFriend(ds.data['inviter'], ds.data['invitee']);

    _store.collection('friendInvitation').document(invitationUID).delete();

    return Future.value(true);
  }

  static Future<bool> declineFriendRequest(String invitationUID) async {
    _store.collection('friendInvitation').document(invitationUID).delete();
    return Future.value(true);
  }

  /*
    Get user details on with given uuid.
  */
  static Future<User> getUserDetails(FirebaseUser firebaseUser) async {
    DocumentSnapshot d =
        await _store.collection('userDetails').document(firebaseUser.uid).get();

    // TODO: sean please delete this soon, just for debugging
    if (d.data == null) {
      print('THIS SHOULD NEVER HAPPEN!!!!!!!!!!!!!!!!!!!!!!!!!!');
      return User(uuid: '', email: '', image: '', name: 'MISTAKE');
    }
    return User.fromDocument(d);
  }

  /*
    Get all users with displayName matching keyWord (prefix only!).
  */
  static Future<List<User>> getUsersByDisplayNameWith(String keyWord) async {
    QuerySnapshot q = await _store
        .collection('userDetails')
        .where(
          'displayName',
          isEqualTo: keyWord,
        )
        .getDocuments();
    return q.documents.map((ds) {
      return User.fromDocument(ds);
    }).toList();
  }

  static Future<List<Friendship>> getFriendShipsByDisplayNameWith(
      String keyWord, String userUID) async {
    List<User> users = await getUsersByDisplayNameWith(keyWord);
    List<Future<Friendship>> fs = users.map((user) async {
      DocumentSnapshot ds = await _store
          .collection('friends')
          .document(userUID)
          .collection('friendRecords')
          .document(user.uuid)
          .get();

      FriendshipStatus status;
      if (ds.data != null) {
        status = FriendshipStatus.Friends;
      } else {
        QuerySnapshot qs = await _store
            .collection('friendInvitation')
            .where('inviter', isEqualTo: userUID)
            .where('invitee', isEqualTo: user.uuid)
            .getDocuments();
        status = qs.documents.length > 0
            ? FriendshipStatus.Pending
            : FriendshipStatus.Strangers;
      }
      return Friendship(friend: user, friendshipStatus: status);
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
          user: User.fromDocument(ds), invitationUID: document.documentID);
    }).toList();

    return await Future.wait(futures);
  }

  static Future<bool> sendChallengeFromTo(
      String userUID, String targetUID, List<String> wordPair) {
    _store
        .collection('challenges')
        .document(targetUID)
        .collection('pending')
        .document()
        .setData({
      'challenger': userUID,
      'wordpair': wordPair.toList(),
      'created': DateTime.now().toUtc(),
    });

    return Future.value(true);
  }

  static Future<bool> sendChallengeFromToMany(
      String userUID, List<String> targetUIDs, List<String> wordPair) {
    targetUIDs.forEach((targetUID) {
      sendChallengeFromTo(userUID, targetUID, wordPair);
    });
    return Future.value(true);
  }

  static Future<bool> deleteChallenge(Challenge challenge) {
    _store.collection('challenges').document(challenge.uid).delete();
    return Future.value(true);
  }

  static Future<FriendRecord> getFriendRecord(
      String userUID, String challengerUID) async {
    DocumentSnapshot ds = await _store
        .collection('friends')
        .document(userUID)
        .collection('friendRecords')
        .document(challengerUID)
        .get();

    return FriendRecord.fromDocument(ds);
  }

  static Future<bool> updateScoreWithFriend(
      String userUID, String challengerUID, int newScore) async {
    _store
        .collection('friends')
        .document(userUID)
        .collection('friendRecords')
        .document(challengerUID)
        .setData(
      {
        'score': newScore,
      },
      merge: true,
    );

    return Future.value(true);
  }

  // STREAMS
  static Stream<List<Challenge>> pendingChallengesStreamFor(String userUID) {
    return _store
        .collection('challenges')
        .document(userUID)
        .collection('pending')
        .orderBy('created', descending: true)
        .snapshots()
        .handleError((onError) {
      print(onError.details);
    }).asyncMap((qs) async {
      List<Future<Challenge>> futures = qs.documents.map((doc) async {
        List<dynamic> futures = await Future.wait([
          _store
              .collection('userDetails')
              .document(doc.data['challenger'])
              .get(),
          getFriendRecord(userUID, doc.data['challenger']),
        ]);

        Friend challenger = Friend.fromDocument(futures[0]);
        challenger.score = (futures[1] as FriendRecord).score;

        return new Challenge(
          uid: doc.documentID,
          challenger: challenger,
          wordPair: doc.data['wordpair'].cast<String>(),
        );
      }).toList();

      return await Future.wait(futures);
    });
  }

  static Stream<List<Invitation>> pendingInvitationsStreamFor(String userUID) {
    return _store
        .collection('friendInvitation')
        .where('invitee', isEqualTo: userUID)
        .snapshots()
        .asyncMap((qs) async {
          List<Future<Invitation>> futures = qs.documents.map((document) async {
            DocumentSnapshot ds = await _store
              .collection('userDetails')
              .document(document['inviter'])
              .get();

          return Invitation(user: User.fromDocument(ds), invitationUID: document.documentID);
      }).toList();
      return await Future.wait(futures);
    });
  }

  static Stream<List<Friend>> friendsStreamFor(String userUID) {
    return _store
        .collection('friends')
        .document(userUID)
        .collection('friendRecords')
        .snapshots()
        .asyncMap((qs) async {
          List<Future<Friend>> futures = qs.documents.map((document) async {
            DocumentSnapshot ds = await
              _store
                  .collection('userDetails')
                  .document(document.documentID)
                  .get();
            
            Friend friend = Friend.fromDocument(ds);
            FriendRecord fr = FriendRecord.fromDocument(document);

            friend.score = fr.score ?? 0;
            return friend;
          }).toList();
          
          return await Future.wait(futures);
        });
  }
}
