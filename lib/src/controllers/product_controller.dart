import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/domain/part.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';
import 'package:synthecure/src/repositories/product_repository.dart';

class AdminProductController
    extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Empty method - no need to do anything in the build method
  }

  // Method to add a new part
  Future<bool> addProduct({required Part product}) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository = ref.read(productRepositoryProvider);

    state = await AsyncValue.guard(
      () => repository.addProduct(product: product),
    );

    return state.hasError == false;
  }

  // // Method to delete a part
  Future<bool> deleteProduct({required Part part}) async {
    // Set loading state
    state = const AsyncLoading().copyWithPrevious(state);

    final repository = ref.read(productRepositoryProvider);


        await Future.delayed(Duration(seconds: 2));

    state = await AsyncValue.guard(
      () => repository.deleteProduct(product: part),
    );

    return state.hasError == false;
  }

  // Method to update a part's details
  // Future<bool> updatePart({required Part part, required String updatedName}) async {
  //   final currentUser = ref.read(authRepositoryProvider).currentUser;
  //   if (currentUser == null) {
  //     throw AssertionError('User can\'t be null');
  //   }

  //   // Set loading state
  //   state = const AsyncLoading().copyWithPrevious(state);

  //   final repository = ref.read(partRepositoryProvider);

  //   state = await AsyncValue.guard(
  //     () => repository.updatePart(part: part, newName: updatedName),
  //   );

  //   return state.hasError == false;
  // }
}

final adminPartControllerProvider =
    AutoDisposeAsyncNotifierProvider<AdminProductController,
        void>(
  AdminProductController.new,
);

final adminPartDeleteControllerProvider =
    AutoDisposeAsyncNotifierProvider<AdminProductController,
        void>(
  AdminProductController.new,
);

// final adminPartUpdateControllerProvider = AutoDisposeAsyncNotifierProvider<AdminProductController, void>(
//   AdminProductController.new,
// );
