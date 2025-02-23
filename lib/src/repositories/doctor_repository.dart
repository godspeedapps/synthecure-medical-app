import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/services/doctors_service.dart';

import 'firebase_auth_repository.dart';

final doctorSearchQueryProvider =
    StateProvider<String>((ref) => '');

class DoctorRepository {
  const DoctorRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String allDoctorsPath() => '/doctors';

  Future<void> addDoctor({required String name}) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // Generate a new document reference with an auto-generated ID
      final doctorRef =
          _firestore.collection(allDoctorsPath()).doc();

      // Create doctor data
      final doctorData = {
        'id': doctorRef
            .id, // Store the auto-generated document ID
        'name': name, // Store the provided doctor name
      };

      // Add the doctor document to the batch
      batch.set(doctorRef, doctorData);

      // Commit the batch to Firestore
      await batch.commit();

    } on FirebaseException catch (e) {
      throw Exception("Failed to add doctor: ${e.message}");
    } catch (e) {
      throw Exception(
          "An unexpected error occurred while adding the doctor.");
    }
  }

  Future<void> deleteDoctor(
      {required Doctor doctor}) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // Reference to the doctor document
      final doctorRef = _firestore
          .collection(allDoctorsPath())
          .doc(doctor.id);

      // Delete the doctor document
      batch.delete(doctorRef);


      // Loop through each hospital ID to remove the doctor from the "doctors" array
      // Loop through each hospital where the doctor is listed
      // Loop through each hospital where the doctor is listed
      for (var hospital in doctor.hospitals) {
        final hospitalRef = _firestore
            .collection('hospitals')
            .doc(hospital.id);

        batch.update(hospitalRef, {
          'doctors': FieldValue.arrayRemove([
            {"id": doctor.id, "name": doctor.name}
          ])
        });
      }
      // Commit the batch operation
      await batch.commit();

    } on FirebaseException catch (e) {
      throw Exception(
          "Failed to delete doctor: ${e.message}");
    } catch (e) {
      throw Exception(
          "An unexpected error occurred while deleting the doctor.");
    }
  }

  Future<void> updateDoctorHospitals({
    required Doctor doctor,
    required List<Hospital> selectedHospitals,
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // Reference to the doctor document
      final doctorRef =
          _firestore.collection('doctors').doc(doctor.id);

      // Get the previous hospitals list (if any)
      final previousHospitals = doctor.hospitals;

      // Track the added and removed hospitals
      final hospitalsToAdd = selectedHospitals
          .where((newHospital) => !previousHospitals.any(
              (oldHospital) =>
                  oldHospital.id == newHospital.id))
          .toList();

      final hospitalsToRemove = previousHospitals
          .where((oldHospital) => !selectedHospitals.any(
              (newHospital) =>
                  newHospital.id == oldHospital.id))
          .toList();

      // 1. **Replace the hospital list in the doctor's document**
      batch.update(doctorRef, {
        'hospitals': selectedHospitals
            .map((hospital) =>
                {'id': hospital.id, 'name': hospital.name})
            .toList(), // Set the new list of hospitals
      });

      // 2. **Update hospital documents in /hospitals**
      final hospitalsRef =
          _firestore.collection('hospitals');

      // 2a. **For added hospitals:**
      for (var hospital in hospitalsToAdd) {
        final hospitalRef = hospitalsRef.doc(hospital.id);

        batch.update(hospitalRef, {
          'doctors': FieldValue.arrayUnion([
            {'id': doctor.id, 'name': doctor.name}
          ]),
        });
      }

      // 2b. **For removed hospitals:**
      for (var hospital in hospitalsToRemove) {
        final hospitalRef = hospitalsRef.doc(hospital.id);

        final doctorInfoToRemove = {
          'id': doctor.id,
          'name': doctor.name
        };

        batch.update(hospitalRef, {
          'doctors':
              FieldValue.arrayRemove([doctorInfoToRemove]),
        });
      }

      // Commit the batch to Firestore
      await batch.commit();

      
    } on FirebaseException catch (e) {
      throw Exception(
          "Failed to update doctor's hospitals: ${e.message}");
    } catch (e) {
    
      throw Exception(
          "An unexpected error occurred while updating doctor's hospitals.");
    }
  }

  Stream<List<Doctor>> watchAllDoctors() {
    final doctors = queryAllDoctors().snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());

    return doctors;
  }

  Query<Doctor> queryAllDoctors() {
    Query<Doctor> query = _firestore
        .collection(allDoctorsPath())
        .withConverter<Doctor>(
          fromFirestore: (snapshot, _) =>
              Doctor.fromMap(snapshot.data()!),
          toFirestore: (doctor, _) => doctor.toMap(),
        );

    return query;
  }
}

final doctorRepositoryProvider =
    Provider<DoctorRepository>((ref) {
  return DoctorRepository(FirebaseFirestore.instance);
});

final allDoctorsQueryProvider =
    Provider<Stream<List<Doctor>>>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.watchAllDoctors();
});

final filteredDoctorsProvider =
    Provider<AsyncValue<List<Doctor>>>((ref) {
  final searchQuery = ref.watch(doctorSearchQueryProvider);
  final allDoctors =
      ref.watch(doctorsTileModelStreamProvider);

  return allDoctors.whenData((doctors) {
    if (searchQuery.isEmpty) return doctors;
    return doctors
        .where((doctor) => doctor.name
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();
  });
});
