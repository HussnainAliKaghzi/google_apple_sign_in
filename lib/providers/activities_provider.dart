import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activitiesStreamProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance
      .collection('activities')
      .orderBy('dateTime', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList());
});

final userActivitiesProvider = StreamProvider.family((ref, String userId) {
  return FirebaseFirestore.instance
      .collection('activities')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList());
});
