import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/controllers/hospital_controller.dart';
import 'package:synthecure/src/domain/app_user.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/features/admin/users/accounts_view.dart';
import 'package:synthecure/src/repositories/user_repository.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';

class UserAccountController
    extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Empty method - no need to do anything in the build method
  }

  // Method to add a new user
  Future<bool> addUser({
    required String firstName,
    required String lastName,
    required String email,
    required bool isAdmin,
    required List<Hospital> selectedHospitals
  }) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository = ref.read(userRepositoryProvider);

    state = await AsyncValue.guard(
      () => repository.addUserAuth(
          firstName, lastName, email, isAdmin, selectedHospitals),
    );

     //Clear selection providers

    ref.read(selectedHospitalsProvider.notifier).clear();

    return state.hasError == false;
  }

  // Method to update user details (name, etc.)
  Future<bool> updateUserDetails({
    required String firstName,
    required String lastName,
    required String userId,
  }) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository = ref.read(userRepositoryProvider);

    state = await AsyncValue.guard(
      () => repository.updateAuthName(
          firstName, lastName, userId),
    );

    return state.hasError == false;
  }

  // Method to update user to admin status
  Future<bool> makeUserAdmin(
      {required String email}) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository = ref.read(userRepositoryProvider);

    state = await AsyncValue.guard(
      () => repository.makeUserAdmin(email),
    );

    return state.hasError == false;
  }

  // Method to delete a user
  Future<bool> deleteUser({required AppUser user}) async {
    // // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final currentUser =
        ref.read(authRepositoryProvider).currentUser;

    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    final repository = ref.read(userRepositoryProvider);

    state = await AsyncValue.guard(
      () => repository.deleteUser(user),
    );

    return state.hasError == false;
  }

  // Method to update doctors's hospitals
  Future<bool> updateUsersHospitals(
      {
        required AppUser userToUpdate,
        required List<Hospital> updatedHospitals}) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository =
        ref.read(userRepositoryProvider);

    state = await AsyncValue.guard(() =>
        repository.updateUserHospitals(user: userToUpdate, selectedHospitals: updatedHospitals));

    //Clear selection providers && update local state


    ref.read(userAccountPageProvider.notifier).update(
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

final userAccountControllerProvider =
    AutoDisposeAsyncNotifierProvider<UserAccountController,
        void>(
  UserAccountController.new,
);


final userUpdateHospitalsControllerProvider =
    AutoDisposeAsyncNotifierProvider<UserAccountController,
        void>(
  UserAccountController.new,
);
