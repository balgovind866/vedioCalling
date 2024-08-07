import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thebear/resource/storage_methods.dart';

import 'package:uuid/uuid.dart';

import '../models/livestream.dart';
import '../providers/user_provider.dart';
import '../utils/utils.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageMethods _storageMethods = StorageMethods();

  Future<String> startLiveStream(
      BuildContext context, String audianse, ) async {
    final user = Provider.of<UserProvider>(context, listen: false);
    String channelId = '';
    try {

      DocumentSnapshot doc = await _firestore.collection('livestream').doc('${user.user.uid}${user.user.username}').get();

      if (doc.exists) {
        // Delete the existing livestream data
        await _firestore.collection('livestream').doc('${user.user.uid}${user.user.username}').delete();
      }

      channelId = '${user.user.uid}${user.user.username}';

      LiveStream liveStream = LiveStream(
        title: 'bear',
        uid: user.user.uid,
        username: user.user.username,
        viewers: 0,
        channelId: channelId,
        startedAt: DateTime.now(),
      );

      await _firestore.collection('livestream').doc(channelId).set(liveStream.toMap());


      }  on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
    return channelId;
  }

  Future<void> chat(String text, String id, BuildContext context) async {
    final user = Provider.of<UserProvider>(context, listen: false);

    try {
      String commentId = const Uuid().v1();
      await _firestore
          .collection('livestream')
          .doc(id)
          .collection('comments')
          .doc(commentId)
          .set({
        'username': user.user.username,
        'message': text,
        'uid': user.user.uid,
        'createdAt': DateTime.now(),
        'commentId': commentId,
      });
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  // Future<void> updateViewCount(String id, bool isIncrease) async {
  //   try {
  //     await _firestore.collection('livestream').doc(id).update({
  //       'viewers': FieldValue.increment(isIncrease ? 1 : -1),
  //     });
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  Future<void> endLiveStream(String channelId) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection('livestream')
          .doc(channelId)
          .collection('comments')
          .get();

      for (int i = 0; i < snap.docs.length; i++) {
        await _firestore
            .collection('livestream')
            .doc(channelId)
            .collection('comments')
            .doc(
              ((snap.docs[i].data()! as dynamic)['commentId']),
            )
            .delete();
      }
      await _firestore.collection('livestream').doc(channelId).delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }


}
