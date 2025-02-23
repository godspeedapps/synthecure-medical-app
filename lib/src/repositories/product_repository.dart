import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/domain/part.dart';

import 'firebase_auth_repository.dart';

class ProductRepository {
  const ProductRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String allProductsPath() => '/products';

  Stream<List<Part>> watchAllProducts() {
    final products = queryAllProducts().snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());

    return products;
  }

  Query<Part> queryAllProducts() {
    Query<Part> query = _firestore
        .collection(allProductsPath())
        .withConverter<Part>(
          fromFirestore: (snapshot, _) =>
              Part.fromMap(snapshot.data()!),
          toFirestore: (product, _) => product.toMap(),
        );

    return query;
  }

  Future<void> addProduct({required Part product}) async {
    try {
      final productRef =
          _firestore.collection(allProductsPath());
      final productId = productRef.doc().id;

      await productRef
          .doc(productId)
          .set(product.toGeneralMap(id: productId));
    } on FirebaseException catch (e) {
      throw Exception("Failed to add part: ${e.message}");
    } catch (e) {
      throw Exception(
          "An unexpected error occurred while adding the part.");
    }
  }

  // Future<void> updatePart(String partId, Part updatedPart) async {
  //   await _firestore.collection(allProductsPath()).doc(partId).update(updatedPart.toMap());
  // }

  Future<void> deleteProduct(
      {required Part product}) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // Loop through each hospital associated with the product
      for (final hospital in product.hospitals) {
     
        final hospitalRef = _firestore
            .collection('hospitals')
            .doc(hospital.id);

        // 1. Remove the product from the hospital's 'products' array
        batch.update(hospitalRef, {
          'products': FieldValue.arrayRemove([
            product.copyWith(price: hospital.price, hospitals: []).toMap()
          ]),
        });
      }

      // 3. Delete the product document itself
      batch.delete(_firestore
          .collection(allProductsPath())
          .doc(product.id));

      // Commit the batch to Firestore
      await batch.commit();

    } on FirebaseException catch (e) {

      throw Exception(
          "Failed to delete product and its relationships: ${e.message}");
    } catch (e) {

      throw Exception(
          "An unexpected error occurred while deleting the product.");
    }
  }
}

final productRepositoryProvider =
    Provider<ProductRepository>((ref) {
  return ProductRepository(FirebaseFirestore.instance);
});

final allProductsQueryProvider =
    Provider<Stream<List<Part>>>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final repository = ref.watch(productRepositoryProvider);
  return repository.watchAllProducts();
});
