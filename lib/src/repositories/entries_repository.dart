import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/domain/order.dart'
    as model;

import 'firebase_auth_repository.dart';
import '../domain/app_user.dart';

class EntriesRepository {
  const EntriesRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String entryPath(String uid, String entryId) =>
      'users/$uid/orders/$entryId';
  static String entriesPath(String uid) =>
      'users/$uid/orders';

  // delete
  Future<void> deleteEntry(
          {required UserID uid,
          required model.OrderID entryId}) =>
      _firestore.doc(entryPath(uid, entryId)).delete();

  // read
  Stream<List<model.Order>> watchEntries(
          {required UserID uid, model.OrderID? orderId}) =>
      queryEntries(uid: uid, jobId: orderId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .toList());


  Stream<List<model.Order>> watchPastEntries(
          {required UserID uid, model.OrderID? orderId}) =>
      queryPastEntries(uid: uid, jobId: orderId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .toList());

  Query<model.Order> queryEntries(
      {required UserID uid, model.OrderID? jobId}) {
    Query<model.Order> query = _firestore
        .collection(entriesPath(uid))
        .withConverter<model.Order>(
          fromFirestore: (snapshot, _) =>
              model.Order.fromMap(
                  snapshot.data()!, snapshot.id),
          toFirestore: (entry, _) => entry.toMap(),
        );

    if (jobId != null) {
      query = query.where('jobId', isEqualTo: jobId);
    }
    return query;
  }

  Query<model.Order> queryPastEntries(
      {required UserID uid, model.OrderID? jobId}) {
    Query<model.Order> query = _firestore
        .collection(entriesPath(uid))
        .withConverter<model.Order>(
          fromFirestore: (snapshot, _) =>
              model.Order.fromMap(
                  snapshot.data()!, snapshot.id),
          toFirestore: (entry, _) => entry.toMap(),
        );
    if (jobId != null) {
      query = query.where('jobId', isEqualTo: jobId);
    }
    return query.where("isClosed", isEqualTo: true);
  }


  // *** ADMIN METHODS ****

  Stream<List<model.Order>> watchAllOrders({model.OrderID? orderId}) =>
    queryAllOrders(jobId: orderId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());

  
  
  Query<model.Order> queryAllOrders({model.OrderID? jobId}) {
  Query<model.Order> query = _firestore
      .collection('orders') // Root collection for all orders
      .withConverter<model.Order>(
        fromFirestore: (snapshot, _) => model.Order.fromMap(snapshot.data()!, snapshot.id),
        toFirestore: (entry, _) => entry.toMap(),
      );

  if (jobId != null) {
    query = query.where('jobId', isEqualTo: jobId);
  }

  return query;
}



 Stream<List<model.Order>> watchHospitalOrders({required String hospitalId}) =>
    queryHospitalOrders(hospitalId: hospitalId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());


  
  Query<model.Order> queryHospitalOrders({required String hospitalId}) {
  Query<model.Order> query = _firestore
      .collection('hospitals/$hospitalId/orders') // Root collection for all orders
      .withConverter<model.Order>(
        fromFirestore: (snapshot, _) => model.Order.fromMap(snapshot.data()!, snapshot.id),
        toFirestore: (entry, _) => entry.toMap(),
      );

  return query;
}


 Stream<List<model.Order>> watchDoctorsOrders({required String doctorId}) =>
    queryDoctorsOrders(doctorId: doctorId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());


  
  Query<model.Order> queryDoctorsOrders({required String doctorId}) {
  Query<model.Order> query = _firestore
      .collection('doctors/$doctorId/orders') // Root collection for all orders
      .withConverter<model.Order>(
        fromFirestore: (snapshot, _) => model.Order.fromMap(snapshot.data()!, snapshot.id),
        toFirestore: (entry, _) => entry.toMap(),
      );

  return query;
}

}



final entriesRepositoryProvider =
    Provider<EntriesRepository>((ref) {
  return EntriesRepository(FirebaseFirestore.instance);
});


//*** QUERY USER SPECIFIC ENTRY */

final jobEntriesQueryProvider = Provider.autoDispose
    .family<Query<model.Order>, model.OrderID>(
        (ref, jobId) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw AssertionError(
        'User can\'t be null when fetching jobs');
  }
  final repository = ref.watch(entriesRepositoryProvider);
  return repository.queryEntries(
      uid: user.uid, jobId: jobId);
});


//*** ADMIN QUERY FOR ALL ORDERS */

final adminOrdersQueryProvider =
    Provider.autoDispose.family<Query<model.Order>, model.OrderID?>(
  (ref, jobId) {
    final repository = ref.watch(entriesRepositoryProvider);
    return repository.queryAllOrders(jobId: jobId);
  },
);


