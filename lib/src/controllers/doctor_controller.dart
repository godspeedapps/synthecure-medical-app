import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/controllers/hospital_controller.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/features/admin/doctors/doctor_page.dart';
import 'package:synthecure/src/repositories/doctor_repository.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';

class AdminDoctorController
    extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Empty method - no need to do anything in the build method
  }

  // Method to add a new user
  Future<bool> addDoctor({required String name}) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository = ref.read(doctorRepositoryProvider);

    state = await AsyncValue.guard(
      () => repository.addDoctor(name: name),
    );

    return state.hasError == false;
  }

  // Method to delete a hospital
  Future<bool> deleteDoctor(
      {required Doctor doctor}) async {
    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository = ref.read(doctorRepositoryProvider);

    state = await AsyncValue.guard(
      () => repository.deleteDoctor(doctor: doctor),
    );

    return state.hasError == false;
  }

  // Method to update doctors's hospitals
  Future<bool> updateDoctorHospitals(
      {required Doctor doctor,
      required List<Hospital> updatedHospitals}) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository =
        ref.read(doctorRepositoryProvider);

    state = await AsyncValue.guard(() =>
        repository.updateDoctorHospitals(doctor: doctor, selectedHospitals: updatedHospitals));

    //Clear selection providers && update local state

    ref.read(doctorPageProvider.notifier).update(
        (hospital) => hospital!.copyWith(
            hospitals: updatedHospitals
                .map((e) =>
                    HospitalInfo(id: e.id, name: e.name))
                .toList()));


    Future.delayed(
        Duration(seconds: 1),
        () => ref
            .read(selectedHospitalsProvider.notifier)
            .clear());

    return state.hasError == false;
  }
}

final adminDoctorControllerProvider =
    AutoDisposeAsyncNotifierProvider<AdminDoctorController,
        void>(
  AdminDoctorController.new,
);

final adminDoctorDeleteControllerProvider =
    AutoDisposeAsyncNotifierProvider<AdminDoctorController,
        void>(
  AdminDoctorController.new,
);

final adminDoctorUpdateControllerProvider =
    AutoDisposeAsyncNotifierProvider<AdminDoctorController,
        void>(
  AdminDoctorController.new,
);
