import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/domain/part.dart';
import 'package:synthecure/src/features/admin/hospitals/add_hospital.dart';
import 'package:synthecure/src/features/admin/hospitals/hospital_page.dart';
import 'package:synthecure/src/features/admin/products/product_hospitals.dart';
import 'package:synthecure/src/repositories/hospital_repository.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';

class AdminHospitalController
    extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Empty method - no need to do anything in the build method
  }

  // Method to add a new user
  Future<bool> addHospital(
      {required Hospital hospital}) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository =
        ref.read(hospitalsRepositoryProvider);

    state = await AsyncValue.guard(
      () => repository.addHospital(
          uid: currentUser.uid, hospital: hospital),
    );

    //Clear selection providers

    ref.read(selectedDoctorsProvider.notifier).clear();
    ref.read(selectedProductsProvider.notifier).clear();

    return state.hasError == false;
  }

  // Method to delete a hospital
  Future<bool> deleteHospital(
      {required String hospitalId}) async {
    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository =
        ref.read(hospitalsRepositoryProvider);

    state = await AsyncValue.guard(
      () =>
          repository.deleteHospital(hospitalId: hospitalId),
    );

    return state.hasError == false;
  }

  // Method to update hospital doctors
  Future<bool> updateHospitalDoctors(
      {required Hospital hospital,
      required List<Doctor> updatedDoctors}) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository =
        ref.read(hospitalsRepositoryProvider);

    state = await AsyncValue.guard(() =>
        repository.updateHospitalDoctors(
            uid: currentUser.uid,
            hospital: hospital,
            selectedDoctors: updatedDoctors));

    //Clear selection providers && update local state

    ref.read(hospitalPageProvider.notifier).update(
        (hospital) =>
            hospital!.copyWith(doctors: updatedDoctors));

    Future.delayed(
        Duration(seconds: 1),
        () => ref
            .read(selectedDoctorsProvider.notifier)
            .clear());

    return state.hasError == false;
  }

  // Method to update hospital doctors
  Future<bool> updateHospitalProducts(
      {required Hospital hospital,
      required List<Part> updatedProducts}) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository =
        ref.read(hospitalsRepositoryProvider);

    state = await AsyncValue.guard(() =>
        repository.updateHospitalProducts(
            uid: currentUser.uid,
            hospital: hospital,
            selectedProducts: updatedProducts));

    //Clear selection providers && update local state

    ref.read(hospitalPageProvider.notifier).update(
        (hospital) =>
            hospital!.copyWith(products: updatedProducts));

    Future.delayed(
        Duration(seconds: 1),
        () => ref
            .read(selectedProductsProvider.notifier)
            .clear());

    return state.hasError == false;
  }

  // Method to update hospital doctors
  Future<bool> updateSingleProductPrice(
      {required Hospital hospital,
      required Part updatedProduct}) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository =
        ref.read(hospitalsRepositoryProvider);

    state = await AsyncValue.guard(() =>
        repository.updateSingleProductPrice(
            uid: currentUser.uid,
            hospital: hospital,
            productToUpdate: updatedProduct));

    // update local state

    ref.read(productPageProvider.notifier).update(
      (product) {
        if (product == null) {
          // Handle null product gracefully
          return product; // Or some other fallback
        }
        return product.copyWith(
          hospitals:
              product.hospitals.map((HospitalInfo e) {
            if (e.id == hospital.id) {
              return e.copyWith(
                  price: updatedProduct
                      .price); // Use copyWith on HospitalInfo
            }
            return e;
          }).toList(),
        );
      },
    );

    return state.hasError == false;
  }

  // Method to update hospital doctors
  Future<bool> deleteProductHospitalRelationship(
      {required Hospital hospital,
      required Part productToDelete}) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository =
        ref.read(hospitalsRepositoryProvider);

    state = await AsyncValue.guard(() =>
        repository.deleteProductHospitalRelationship(
            uid: currentUser.uid,
            hospital: hospital,
            productToDelete: productToDelete));


    // update local state

    ref.read(productPageProvider.notifier).update(
      (product) {
        if (product == null) {
          // Handle null product gracefully
          return product; // Or some other fallback value
        }

        // Remove the hospital from the hospitals list if it exists
        final updatedHospitals =
            product.hospitals.where((HospitalInfo e) {
          return e.id !=
              hospital
                  .id; // Only keep hospitals that do not match the given hospital id
        }).toList();

        // Return the updated product with the modified hospitals list
        return product.copyWith(
            hospitals: updatedHospitals);
      },
    );

    // ref.read(hospitalPageProvider.notifier).update(
    //     (hospital) =>
    //         hospital!.copyWith(products: updatedProducts));

    return state.hasError == false;
  }
}

final adminHospitalControllerProvider =
    AutoDisposeAsyncNotifierProvider<
        AdminHospitalController, void>(
  AdminHospitalController.new,
);

final adminHospitalRemoveProductControllerProvider =
    AutoDisposeAsyncNotifierProvider<
        AdminHospitalController, void>(
  AdminHospitalController.new,
);

final adminHospitalDeleteControllerProvider =
    AutoDisposeAsyncNotifierProvider<
        AdminHospitalController, void>(
  AdminHospitalController.new,
);




final selectedHospitalsProvider = StateNotifierProvider<
    SelectedHospitalsNotifier, List<Hospital>>(
  (ref) => SelectedHospitalsNotifier(),
);

class SelectedHospitalsNotifier
    extends StateNotifier<List<Hospital>> {
  SelectedHospitalsNotifier() : super([]);

  // Add or remove a doctor
  // Add or remove a Product
  void toggleHospitalSelection(Hospital hospital) {
    if (state.any((item) => item.id == hospital.id)) {
      // Remove the product by id
      state = state
          .where((item) => item.id != hospital.id)
          .toList();
    } else {
      // Add the product with a modified price (copying and changing only the price)
      state = [...state, hospital];
    }
  }

  // Set the initial list of doctors
  void setHospitals(List<Hospital> hospitals) {
    state = hospitals;
  }

  // Clear all selected doctors
  void clear() {
    state = [];
  }
}
