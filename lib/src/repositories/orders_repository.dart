import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/domain/part.dart';
import 'package:synthecure/src/services/hospitals_service.dart';

import 'firebase_auth_repository.dart';
import '../domain/app_user.dart';

import '../domain/order.dart' as model;
import '../domain/order.dart';

final hospitalProvider =
    StateProvider<Hospital?>((_) => null);

class OrdersRepository {
  const OrdersRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String orderPath(String uid, String jobId) =>
      'users/$uid/orders/$jobId';
  static String allOrdersPath(String jobId) =>
      'orders/$jobId';
  static String ordersPath(String uid) =>
      'users/$uid/orders';
  static String hospitalsPath() => 'hospitals';
  static String doctorsPath(String uid, String hid) =>
      'hospitals/$hid/hospitals';

  // static String entriesPath(String uid) => EntriesRepository.entriesPath(uid);

// *** ADD CASE SHEET ****
  Future<model.Order?> addJob({
    required UserID uid,
    required Map<String, dynamic> order,
    required List<Part> products,
  }) async {
    // Create a batch to perform atomic writes
    final batch = _firestore.batch();

    // Reference to user's orders collection
    final userOrdersRef =
        _firestore.collection(ordersPath(uid));

    // Reference to the general orders collection
    final generalOrdersRef =
        _firestore.collection('orders');

    // Get the hospital ID
    final String hospitalId =
        (order['hospital'] as Hospital).id;

    // Get the doctor ID
    final String doctorId = (order['doctor'] as Doctor).id;

    // Reference to the hospital's orders collection
    final hospitalOrdersRef = _firestore
        .collection('hospitals')
        .doc(hospitalId)
        .collection('orders');

    // Reference to the doctor's orders collection
    final doctorOrdersRef = _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('orders');

    // Generate a unique document ID
    final orderId = userOrdersRef.doc().id;

    

    // Common order data
    final orderData = {
      'orderId': orderId, // ✅ Add the same orderId
      'date': order['date'],
      'doctor':
          ((order['doctor'] as Doctor).copyWith()).toMap(),
      'hospital': ((order['hospital'] as Hospital)).toMap(
          includeProducts: false, includeDoctors: false),
      'products': products.map((e) => (e).toMap()).toList(),
      'patient': order['patient'],
      'notes': order['notes'],
      'isClosed': false,
      'createdBy': uid,
      'isRestock' : order['isRestock'],
      'total': products.fold(0.0, (summer, product) => summer + (product.price * product.quantity)),
      'productCount' : products.fold(0.0, (summer, product) => summer + product.quantity),
    };

    // Add all write operations to the batch
    batch.set(userOrdersRef.doc(orderId), orderData);
    batch.set(generalOrdersRef.doc(orderId), orderData);
    batch.set(hospitalOrdersRef.doc(orderId), orderData);
    batch.set(doctorOrdersRef.doc(orderId), orderData);

    try {
      // Commit the batch
      await batch.commit();

      return model.Order(
        createdBy: uid,
        isClosed: false,
        id: orderId,
        doctor: order["doctor"] as Doctor,
        hospital: (order['hospital'] as Hospital),
        part: products,
        date: order['date'],
        patient: order['patient'],
        notes: order['notes'],
        isRestock: order['isRestock']
      );


      
    } on FirebaseException catch (e) {
      throw Exception("Error adding case sheet: $e");
    } catch (e) {
      throw Exception("Unknown Error adding case sheet $e");
    }
  }

  Future<model.Order?> updateJob({
    required UserID uid,
    required model.Order order,
  }) async {
    // Reference to user's order document
    try {
      final userOrderRef =
          _firestore.doc(orderPath(uid, order.id));

      // Reference to general order document
      final generalOrderRef =
          _firestore.collection('orders').doc(order.id);

      // Perform updates to both documents
      await Future.wait([
        userOrderRef
            .update(order.toMap()), // Update user's order
        generalOrderRef
            .update(order.toMap()), // Update general order
      ]);

      return order;
    } on FirebaseException catch (e) {
      throw Exception("Error adding case sheet: $e");
    } catch (e) {
      throw Exception("Unknown Error adding case sheet $e");
    }
  }

  Stream<List<Hospital>> watchHospitals(
      {required UserID uid}) {
    final hospitals = queryHospitals(uid: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());

    return hospitals;
  }

  Stream<List<Hospital>> watchUserHospitals(
      {required UserID uid}) {
    final userRef = _firestore.collection('users').doc(uid);
    final hospitalsRef = _firestore.collection('hospitals');

    return userRef.snapshots().asyncMap((doc) async {
      if (!doc.exists) return [];

      final data = doc.data();
      if (data == null || data['hospitals'] == null) {
        return [];
      }

      final Set<String> hospitalIds =
          (data['hospitals'] as List)
              .map((hospitalData) =>
                  hospitalData['id'] as String)
              .toSet();

      if (hospitalIds.isEmpty) return [];

      // Fetch all hospitals and filter in memory
      final querySnapshot = await hospitalsRef.get();

      return querySnapshot.docs
          .map(
              (doc) => Hospital.fromMap(doc.data(), doc.id))
          .where((hospital) =>
              hospitalIds.contains(hospital.id))
          .toList();
    });
  }

  Stream<List<Doctor>> watchDoctors(
      {required UserID uid, required HospitalID hid}) {
    final hospitals = queryDoctors(uid: uid, hid: hid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());

    return hospitals;
  }

  Query<Doctor> queryDoctors(
      {required UserID uid, required HospitalID hid}) {
    Query<Doctor> query = _firestore
        .collection(doctorsPath(uid, hid))
        .withConverter<Doctor>(
          fromFirestore: (snapshot, _) =>
              Doctor.fromMap(snapshot.data()!),
          toFirestore: (doctor, _) => doctor.toMap(),
        );

    return query;
  }

  Query<Hospital> queryHospitals({required UserID uid}) {
    Query<Hospital> query = _firestore
        .collection(hospitalsPath())
        .withConverter<Hospital>(
          fromFirestore: (snapshot, _) => Hospital.fromMap(
              snapshot.data()!, snapshot.id),
          toFirestore: (hospital, _) => hospital.toMap(),
        );

    return query;
  }

  // *** DELETE CASE SHEET FROM COLLECTIONS
  Future<void> deleteJob({
    required UserID uid,
    required OrderID orderId,
    required String hospitalId,
    required String doctorId,
  }) async {
    final batch = _firestore.batch();

    // References to the job in various collections
    final jobRef = _firestore.doc(orderPath(uid, orderId));
    final jobGeneralRef =
        _firestore.doc(allOrdersPath(orderId));
    final hospitalOrderRef = _firestore
        .collection('hospitals')
        .doc(hospitalId)
        .collection('orders')
        .doc(orderId);
    final doctorOrderRef = _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('orders')
        .doc(orderId);

    // Add delete operations to the batch
    batch.delete(jobRef);
    batch.delete(jobGeneralRef);
    batch.delete(hospitalOrderRef);
    batch.delete(doctorOrderRef);

    try {
      // Commit the batch
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception("Error deleteing case sheet: $e");
    } catch (e) {
      throw Exception(
          "Unknown Error deleteing case sheet $e");
    }
  }

  // read
  Stream<model.Order> watchJob(
          {required UserID uid, required OrderID jobId}) =>
      _firestore
          .doc(orderPath(uid, jobId))
          .withConverter<model.Order>(
            fromFirestore: (snapshot, _) =>
                model.Order.fromMap(
                    snapshot.data()!, snapshot.id),
            toFirestore: (job, _) => job.toMap(),
          )
          .snapshots()
          .map((snapshot) => snapshot.data()!);

  Stream<List<model.Order>> watchJobs(
          {required UserID uid}) =>
      queryJobs(uid: uid).snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => doc.data()).toList());

  Query<model.Order> queryJobs({required UserID uid}) =>
      _firestore.collection(ordersPath(uid)).withConverter(
            fromFirestore: (snapshot, _) =>
                model.Order.fromMap(
                    snapshot.data()!, snapshot.id),
            toFirestore: (job, _) => job.toMap(),
          );

  Future<List<model.Order>> fetchJobs(
      {required UserID uid}) async {
    final jobs = await queryJobs(uid: uid).get();
    return jobs.docs.map((doc) => doc.data()).toList();
  }
}

final ordersRepositoryProvider =
    Provider<OrdersRepository>((ref) {
  return OrdersRepository(FirebaseFirestore.instance);
});

final hospitalQueryProvider =
    Provider<Stream<List<Hospital>>>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final repository = ref.watch(ordersRepositoryProvider);
  return repository.watchHospitals(uid: user.uid);
});

final usersHospitalQueryProvider =
    Provider<Stream<List<Hospital>>>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final repository = ref.watch(ordersRepositoryProvider);
  return repository.watchUserHospitals(uid: user.uid);
});

final doctorsQueryProvider =
    Provider.family<Stream<List<Doctor>>, HospitalID>(
        (ref, hid) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final repository = ref.watch(ordersRepositoryProvider);
  return repository.watchDoctors(uid: user.uid, hid: hid);
});

final jobsQueryProvider =
    Provider<Query<model.Order>>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final repository = ref.watch(ordersRepositoryProvider);
  return repository.queryJobs(uid: user.uid);
});

final jobStreamProvider = StreamProvider.autoDispose
    .family<model.Order, OrderID>((ref, jobId) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final repository = ref.watch(ordersRepositoryProvider);
  return repository.watchJob(uid: user.uid, jobId: jobId);
});

final hospitalSearchQueryProvider =
    StateProvider<String>((ref) => '');

final filteredHospitalsProvider =
    Provider<AsyncValue<List<Hospital>>>((ref) {
  final searchQuery =
      ref.watch(hospitalSearchQueryProvider);
  final allHospitals =
      ref.watch(hospitalsTileModelStreamProvider);

  return allHospitals.whenData((hospitals) {
    if (searchQuery.isEmpty) return hospitals;
    return hospitals
        .where((hospital) => hospital.name
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();
  });
});
