import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/domain/app_user.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/domain/part.dart';

class HospitalRepository {
  const HospitalRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String hospitalsPath() => 'hospitals';

  Future<void> addHospital({
    required UserID uid,
    required Hospital hospital,
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // Reference to the hospitals collection
      final hospitalRef =
          _firestore.collection(hospitalsPath());

      // Generate a unique document ID for the hospital
      final hospitalId = hospitalRef.doc().id;

      // Create the hospital document
      batch.set(hospitalRef.doc(hospitalId),
          hospital.copyWith(id: hospitalId).toMap());

      // Create a HospitalInfo object
      final newHospitalInfo = HospitalInfo(
        id: hospitalId,
        name: hospital.name,
      );

      // **Update Doctors' hospitalInfo**
      final doctorsRef = _firestore.collection('doctors');
      for (var doctor in hospital.doctors!) {
        final doctorRef = doctorsRef.doc(doctor.id);

        // Add the new hospitalInfo using arrayUnion
        batch.update(doctorRef, {
          'hospitals': FieldValue.arrayUnion(
              [newHospitalInfo.toMap()])
        });
      }

      // **Update Products' hospitalInfo**
      final productsRef = _firestore.collection('products');
      for (var product in hospital.products!) {
        final productRef = productsRef.doc(product.id);

        HospitalInfo productHospitalInfo = HospitalInfo(
            id: hospitalId,
            name: hospital.name,
            price: product.price);

        // Add the new hospitalInfo using arrayUnion
        batch.update(productRef, {
          'hospitals': FieldValue.arrayUnion(
              [productHospitalInfo.toMap()])
        });
      }

      // Commit the batch to Firestore
      await batch.commit();

    } on FirebaseException catch (e) {
      // Handle Firestore-specific errors
      throw Exception(
          "Failed to add hospital: ${e.message}");
    } catch (e) {
      // Handle other unexpected errors
      throw Exception(
          "An unexpected error occurred while adding the hospital.");
    }
  }

  Future<void> deleteHospital(
      {required String hospitalId}) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // Reference to the specific hospital document
      final hospitalRef = _firestore
          .collection(hospitalsPath())
          .doc(hospitalId);

      // Delete the hospital document
      batch.delete(hospitalRef);

      // Remove the hospital info from each doctor in the /doctors collection
      final doctorsRef = _firestore.collection('doctors');
      final doctorsSnapshot = await doctorsRef.get();

      for (var doc in doctorsSnapshot.docs) {
        final doctorRef = doctorsRef.doc(doc.id);

        // Get the current hospitalInfo array from the doctor's document
        final doctorData = doc.data();
        final hospitalInfoList =
            List<Map<String, dynamic>>.from(
                doctorData['hospitals'] ?? []);

        // Find and remove the hospital info from the list
        final hospitalInfoToRemove =
            hospitalInfoList.firstWhere(
          (hospitalInfo) =>
              hospitalInfo['id'] == hospitalId,
          orElse: () => {},
        );

        if (hospitalInfoToRemove.isNotEmpty) {
          batch.update(doctorRef, {
            'hospitals': FieldValue.arrayRemove(
                [hospitalInfoToRemove])
          });
        }
      }

      // Remove the hospital info from each product in the /products collection
      final productsRef = _firestore.collection('products');
      final productsSnapshot = await productsRef.get();

      for (var doc in productsSnapshot.docs) {
        final productRef = productsRef.doc(doc.id);

        // Get the current hospitalInfo array from the product's document
        final productData = doc.data();
        final hospitalInfoList =
            List<Map<String, dynamic>>.from(
                productData['hospitals'] ?? []);

        // Find and remove the hospital info from the list
        final hospitalInfoToRemove =
            hospitalInfoList.firstWhere(
          (hospitalInfo) =>
              hospitalInfo['id'] == hospitalId,
          orElse: () => {},
        );

        if (hospitalInfoToRemove.isNotEmpty) {
          batch.update(productRef, {
            'hospitals': FieldValue.arrayRemove(
                [hospitalInfoToRemove])
          });
        }
      }

      // Commit the batch to Firestore
      await batch.commit();

    } on FirebaseException catch (e) {
      throw Exception(
          "Failed to delete hospital: ${e.message}");
    } catch (e) {
      throw Exception(
          "An unexpected error occurred while deleting the hospital.");
    }
  }

  Future<void> updateHospitalDoctors({
    required UserID uid,
    required Hospital hospital,
    required List<Doctor>
        selectedDoctors, // The new list of selected doctors
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // Reference to the hospital document
      final hospitalRef = _firestore
          .collection(hospitalsPath())
          .doc(hospital.id);

      // Get the previous doctors list (if any)
      final previousDoctors = hospital.doctors ?? [];

      // Track the added and removed doctors
      final doctorsToAdd = selectedDoctors
          .where((newDoctor) => !previousDoctors.any(
              (oldDoctor) => oldDoctor.id == newDoctor.id))
          .toList();

      final doctorsToRemove = previousDoctors
          .where((oldDoctor) => !selectedDoctors.any(
              (newDoctor) => newDoctor.id == oldDoctor.id))
          .toList();

      // 1. **Replace the doctors list in the hospital document**
      batch.update(hospitalRef, {
        'doctors': selectedDoctors
            .map((doc) =>
                doc.copyWith(hospitals: []).toMap())
            .toList(), // Set the new list of doctors
      });

      // 2. **Update doctors' documents:**
      final doctorsRef = _firestore.collection('doctors');

      // 2a. **For added doctors:**
      for (var doctor in doctorsToAdd) {
        final doctorRef = doctorsRef.doc(doctor.id);

        batch.update(doctorRef, {
          'hospitals': FieldValue.arrayUnion([
            {
              'id': hospital.id,
              'name': hospital.name,
            }
          ]),
        });
      }

      // 2b. **For removed doctors:**
      for (var doctor in doctorsToRemove) {
        final doctorRef = doctorsRef.doc(doctor.id);

        // Create a hospital info map with just the 'id' to remove it from the doctor's hospitals list
        final hospitalInfoToRemove = {
          'id': hospital.id,
          'name': hospital
              .name, // Include name if necessary, otherwise only 'id' is fine
        };

        // Remove the hospital reference based on the 'id'
        batch.update(doctorRef, {
          'hospitals': FieldValue.arrayRemove(
              [hospitalInfoToRemove]),
        });
      }

      // Commit the batch to Firestore
      await batch.commit();

    } on FirebaseException catch (e) {
      // Handle Firestore-specific errors
      throw Exception(
          "Failed to update hospital doctors: ${e.message}");
    } catch (e) {
      // Handle other unexpected errors
      throw Exception(
          "An unexpected error occurred while updating hospital doctors.");
    }
  }

  Future<void> updateHospitalProducts({
    required UserID uid,
    required Hospital hospital,
    required List<Part> selectedProducts,
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // Reference to the hospital document
      final hospitalRef = _firestore
          .collection(hospitalsPath())
          .doc(hospital.id);

      // Get the previous products list (if any)
      final previousProducts = hospital.products ?? [];

      // Track added, removed, and updated products
      final productsToAdd = selectedProducts
          .where((newProduct) => !previousProducts.any(
              (oldProduct) =>
                  oldProduct.id == newProduct.id))
          .toList();

      final productsToRemove = previousProducts
          .where((oldProduct) => !selectedProducts.any(
              (newProduct) =>
                  newProduct.id == oldProduct.id))
          .toList();

      final productsToUpdate =
          selectedProducts.where((newProduct) {
        final oldProduct = previousProducts.firstWhere(
          (oldProduct) => oldProduct.id == newProduct.id,
          orElse: () =>
              newProduct, // If not found, treat as new
        );

        return oldProduct.id == newProduct.id &&
            oldProduct.price != newProduct.price;
      }).toList();

      // 1. **Replace the products list in the hospital document**
      batch.update(hospitalRef, {
        'products': selectedProducts
            .map((product) =>
                product.copyWith(hospitals: []).toMap())
            .toList(),
      });

      // 2. **Update products' documents:**
      final productsRef = _firestore.collection('products');

      // 2a. **For added products:**
      for (var product in productsToAdd) {
        final productRef = productsRef.doc(product.id);

        batch.update(productRef, {
          'hospitals': FieldValue.arrayUnion([
            {
              'id': hospital.id,
              'name': hospital.name,
              'price': product.price,
            }
          ]),
        });
      }

      // 2b. **For removed products:**
    for (var product in productsToRemove) {
          final productRef = productsRef.doc(product.id);

          // Get the current product document
          final productSnapshot = await productRef.get();

          if (productSnapshot.exists) {
            final productData = productSnapshot.data() as Map<String, dynamic>;
            final List<dynamic> currentHospitals = productData['hospitals'] ?? [];

            // Remove the hospital from the 'hospitals' array by id
            final updatedHospitals = currentHospitals.where((hospitalData) {
              final hospitalInfo = hospitalData as Map<String, dynamic>;
              return hospitalInfo['id'] != hospital.id; // Remove by id
            }).toList();

            // Update the product document with the new 'hospitals' array
            batch.update(productRef, {'hospitals': updatedHospitals});
          }
        }

      // 2c. **For updated products (price change only):**
      for (var product in productsToUpdate) {
        final productRef = productsRef.doc(product.id);
        final productSnapshot = await productRef.get();

        if (productSnapshot.exists) {
          final productData = productSnapshot.data()
              as Map<String, dynamic>;
          final List<dynamic> currentHospitals =
              productData['hospitals'] ?? [];

          // Find the hospital entry and update its price
          final existingHospitalIndex = currentHospitals
              .indexWhere((h) => h['id'] == hospital.id);

          if (existingHospitalIndex != -1) {
            currentHospitals[existingHospitalIndex] = {
              'id': hospital.id,
              'name': hospital.name,
              'price': product.price, // Update the price
            };
          }

          // Update Firestore with new hospital array
          batch.update(
              productRef, {'hospitals': currentHospitals});
        }
      }

      // Commit the batch to Firestore
      await batch.commit();

    } on FirebaseException catch (e) {
      throw Exception(
          "Failed to update hospital products: ${e.message}");
    } catch (e) {
      throw Exception(
          "An unexpected error occurred while updating hospital products.");
    }
  }


  Future<void> deleteProductHospitalRelationship({
  required UserID uid,
  required Hospital hospital,
  required Part productToDelete,
}) async {
  try {
    final WriteBatch batch = _firestore.batch();

    // Reference to the hospital document
    final hospitalRef = FirebaseFirestore.instance.collection('hospitals').doc(hospital.id);
    final productRef = _firestore.collection('products').doc(productToDelete.id);

    // 1. Remove the hospital from the product's 'hospitals' array
    batch.update(productRef, {
      'hospitals': FieldValue.arrayRemove([
        {'id': hospital.id,
        'name' : hospital.name,
        'price' : productToDelete.price
        } // Remove the hospital by its ID
      ]),
    });

    // 2. Remove the product from the hospital's 'products' array
    batch.update(hospitalRef, {
      'products': FieldValue.arrayRemove([
        productToDelete.toMap()
      ]),
    });

    // Commit the batch to Firestore
    await batch.commit();

  } on FirebaseException catch (e) {
    throw Exception("Failed to delete product-hospital relationship: ${e.message}");
  } catch (e) {
    throw Exception("An unexpected error occurred while deleting the product-hospital relationship.");
  }
}


  Future<void> updateSingleProductPrice({
    required UserID uid,
    required Hospital hospital,
    required Part productToUpdate,
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // Reference to the hospital document
      final hospitalRef = FirebaseFirestore.instance.collection('hospitals').doc(hospital.id);
      final hospitalSnapshot = await hospitalRef.get();

    if (!hospitalSnapshot.exists) {
      return;
    }

    // 2. Get the current products array from the hospital document
    List<dynamic> products = hospitalSnapshot['products'] ?? [];

    // 3. Update the product in the array (update the price)
    final updatedProducts = products.map((productData) {
      // Assuming 'productData' is a map, you can convert it to a Product object
      final product = Part.fromMap(productData); 

      if (product.id == productToUpdate.id) {
        // Update the product's price
        return product.copyWith(price: productToUpdate.price);
      }

      return product; // Return unchanged product
    }).toList();



      // Update the hospital document with the modified product list
      batch.update(hospitalRef, {
        'products': updatedProducts
            .map((product) =>
                product.copyWith(hospitals: []).toMap())
            .toList(),
      });

      // 2. **Update the product document with the new price**


      final productRef = _firestore
          .collection('products')
          .doc(productToUpdate.id);

      // Get the current product document
      final productSnapshot = await productRef.get();

      if (productSnapshot.exists) {
        final productData =
            productSnapshot.data() as Map<String, dynamic>;
        final List<dynamic> currentHospitals =
            productData['hospitals'] ?? [];

        // Find the hospital entry and update its price
        final existingHospitalIndex = currentHospitals
            .indexWhere((h) => h['id'] == hospital.id);

        if (existingHospitalIndex != -1) {
          currentHospitals[existingHospitalIndex] = {
            'id': hospital.id,
            'name': hospital.name,
            'price':
                productToUpdate.price, // Update the price
          };
        }

        // Update the product document with the new hospital array
        batch.update(
            productRef, {'hospitals': currentHospitals});
      }

      // Commit the batch to Firestore
      await batch.commit();

    } on FirebaseException catch (e) {
      throw Exception(
          "Failed to update product price: ${e.message}");
    } catch (e) {
      throw Exception(
          "An unexpected error occurred while updating the product price.");
    }
  }

  Stream<Hospital> getHospitalStream(String hospitalId) {
    return _firestore
        .collection('hospitals')
        .doc(hospitalId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Hospital.fromMap(
            snapshot.data()!, snapshot.id);
      } else {
        throw Exception('Hospital not found');
      }
    });
  }
}

final hospitalsRepositoryProvider =
    Provider<HospitalRepository>((ref) {
  return HospitalRepository(FirebaseFirestore.instance);
});

final hospitalStreamProvider =
    StreamProvider.family<Hospital, String>(
        (ref, hospitalId) {
  final hospitalsRepository =
      ref.watch(hospitalsRepositoryProvider);
  return hospitalsRepository.getHospitalStream(hospitalId);
});
