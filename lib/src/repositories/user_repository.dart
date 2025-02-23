import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/domain/app_user.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/services/user_service.dart';

/// Firestore repository for users
class UserRepository {
  final FirebaseFirestore _firestore;

  const UserRepository(this._firestore);

  static String usersPath() => 'users';

  /// Stream the authenticated user's Firestore document

  Stream<AppUser> streamUser(String userId) {
    final userRef =
        _firestore.collection(usersPath()).doc(userId);

    return userRef.snapshots().map((doc) {

        return AppUser.fromMap(doc.data()!, doc.id);
     
    });
  }

  /// Add a user to Firestore
  Future<void> addUser(AppUser user) async {
    final usersRef = _firestore.collection(usersPath());
    await usersRef.doc(user.uid).set(user.toMap());
  }

  Future<void> addUserAuth(String firstName,
      String lastName, String email, bool isAdmin, List<Hospital> selectedHospitals) async {
    try {
      final HttpsCallable callable = FirebaseFunctions
          .instance
          .httpsCallable('addUser');

      final user = await callable.call(<String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'isAdmin': isAdmin,
        'password': 'password123'
      });


      final String userId = user.data['uid'];

    // Create a batch instance to group the operations
    final WriteBatch batch = _firestore.batch();

    // Reference to the user document
    final userRef = _firestore.collection(usersPath()).doc(userId);

    // Set the user's hospitals in the user document
    batch.set(userRef, {
      'hospitals': selectedHospitals
          .map((hospital) => {'id': hospital.id, 'name': hospital.name})
          .toList(),
    }, SetOptions(merge: true)); // Use merge to avoid overwriting existing data

    // Reference to the hospitals collection
    final hospitalsRef = _firestore.collection('hospitals');

    // Loop through each hospital and update the users array in each hospital
    for (var hospital in selectedHospitals) {
      final hospitalRef = hospitalsRef.doc(hospital.id);

      batch.update(hospitalRef, {
        'users': FieldValue.arrayUnion([
          {'id': userId, 'name': "$firstName $lastName"}
        ])
      });
    }

    // Commit the batch to Firestore
    await batch.commit();

    } on FirebaseFunctionsException catch (e) {
      // Optionally throw a more descriptive error to the caller
      throw Exception('Failed to add user: ${e.message}');
    } catch (e) {
      // Catch other unexpected errors
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> makeUserAdmin(String email) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idToken = await user
            .getIdToken(true); // `true` forces a refresh
      }

      final HttpsCallable callable = FirebaseFunctions
          .instance
          .httpsCallable('updateUserToAdmin');

      final res = await callable
          .call(<String, dynamic>{'email': email});
    } on FirebaseFunctionsException catch (e) {
      // Optionally throw a more descriptive error to the caller
      throw Exception(
          'Failed to make user admin: ${e.message}');
    } catch (e) {
      // Catch other unexpected errors
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> updateAuthName(
      String firstName, String lastName, String id) async {
    try {
      final HttpsCallable callable = FirebaseFunctions
          .instance
          .httpsCallable('updateUserName');

      await callable.call({
        'firstName': firstName,
        'lastName': lastName,
        'id': id,
      });
    } on FirebaseFunctionsException catch (e) {
      // Optionally throw a more descriptive error to the caller
      throw Exception(
          'Failed to update user: ${e.message}');
    } catch (e) {
      // Catch other unexpected errors
      throw Exception('An unexpected error occurred');
    }
  }

  /// Update a user in Firestore
  Future<void> updateUser(AppUser user) async {
    final userRef =
        _firestore.collection(usersPath()).doc(user.uid);
    await userRef.update(user.toMap());
  }

  Future<void> deleteUser(AppUser user) async {
    try {

         // Start a batch to handle the deletion process atomically
            final WriteBatch batch = _firestore.batch();

            // 1. **Remove the user from each hospital's 'users' array**
            final hospitalsRef = _firestore.collection('hospitals');

            for (var hospitalData in user.hospitals) {
              final hospitalId = hospitalData.id;
              final hospitalRef = hospitalsRef.doc(hospitalId);

              // Remove the user from the hospital's 'users' array
              batch.update(hospitalRef, {
                'users': FieldValue.arrayRemove([
                  {'id': user.uid, 'name': "${user.firstName} ${user.lastName}"}
                ]),
              });
            }
            
      // Get an instance of Firebase Functions
      final HttpsCallable callable = FirebaseFunctions
          .instance
          .httpsCallable('deleteUser');

      // Call the function with the email parameter

      await callable.call(<String, dynamic>{
        'email': user.email,
      });


        // Commit the batch to Firestore
      await batch.commit();

      // Handle the response
      // You can print or handle the success message

      // Success
    } on FirebaseFunctionsException catch (e) {
      // Optionally throw a more descriptive error to the caller
      throw Exception('Failed to add user: ${e.message}');
    } catch (e) {
      // Catch other unexpected errors
      throw Exception('An unexpected error occurred');
    }
  }

  /// Watch all users as a stream
  Stream<List<AppUser>> watchUsers() {
    return _firestore
        .collection(usersPath())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Fetch a single user
  Future<AppUser?> getUser(String userId) async {
    final userRef =
        _firestore.collection(usersPath()).doc(userId);
    final doc = await userRef.get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!, doc.id);
    }
    return null;
  }


  Future<void> updateUserHospitals({required AppUser user, 
    required List<Hospital> selectedHospitals,
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // Reference to the user document
     final userRef =
        _firestore.collection(usersPath()).doc(user.uid);

      // Get the previous hospitals list (if any)
      final previousHospitals = user.hospitals;

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
      batch.update(userRef, {
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
          'users': FieldValue.arrayUnion([
            {'id': user.uid, 'name': "${user.firstName} ${user.lastName}"}
          ]),
        });
      }

      // 2b. **For removed hospitals:**
      for (var hospital in hospitalsToRemove) {
        final hospitalRef = hospitalsRef.doc(hospital.id);

        final usersInfoToRemove = {
          'id': user.uid,
          'name': "${user.firstName} ${user.lastName}"
        };

        batch.update(hospitalRef, {
          'users':
              FieldValue.arrayRemove([usersInfoToRemove]),
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
}

final userRepositoryProvider =
    Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

final userSearchQueryProvider =
    StateProvider<String>((ref) => '');

final filteredUsersProvider =
    Provider<AsyncValue<List<AppUser>>>((ref) {
  final searchQuery = ref.watch(userSearchQueryProvider);
  final allUsers = ref.watch(allUsersStreamProvider);

  return allUsers.whenData((users) {
    if (searchQuery.isEmpty) return users;
    final lowerQuery = searchQuery.toLowerCase();

    return users.where((user) {
      final fullName = '${user.firstName} ${user.lastName}'
          .toLowerCase();
      return user.firstName
              .toLowerCase()
              .contains(lowerQuery) ||
          user.lastName
              .toLowerCase()
              .contains(lowerQuery) ||
          fullName.contains(lowerQuery);
    }).toList();
  });
});
