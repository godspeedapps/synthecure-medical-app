import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/domain/part.dart';
import 'package:synthecure/src/features/admin/dashboard/sales_overview.dart';
import 'package:synthecure/src/services/analytics_service.dart';

import '../../../repositories/firebase_auth_repository.dart';
import '../../../repositories/orders_repository.dart';
import '../../../domain/order.dart';

class EditJobScreenController
    extends AutoDisposeAsyncNotifier<Order?> {
  @override
  FutureOr<Order?> build() {
    return null; // No initial order
  }

  Future<Order?> submit({
    OrderID? orderId,
    Order? oldOrder,
    required Map<String, dynamic> data,
    required List<Part> products,
    required bool isClosed,
  }) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    // Set loading state
    state = const AsyncLoading<Order?>()
        .copyWithPrevious(state);

    final repository = ref.read(ordersRepositoryProvider);

 
    state = await AsyncValue.guard(() async {
      final createdOrder = await repository.addJob(
        uid: currentUser.uid,
        order: data,
        products: products,
      );



    Future.delayed(
        Duration(seconds: 2),
        () => ref.refresh(salesOverviewStreamProvider(
            id: ref
                .read(firebaseAuthProvider)
                .currentUser!
                .uid,
            mode: ref.read(selectedTimePeriodProvider))));


      return createdOrder;
    });

    return state
        .value; // Returns the created Order or null if failed
  }

  Future<Order?> updateOrder({
    required Order order,
  }) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }

    // Set loading state
    state = const AsyncLoading<Order?>()
        .copyWithPrevious(state);

    final repository = ref.read(ordersRepositoryProvider);

    state = await AsyncValue.guard(() async {
      final updatedOrder = await repository.updateJob(
        uid: currentUser.uid,
        order: order.copyWith(isClosed: true),
      );
      return updatedOrder;
    });

    return state
        .value; // Returns updated Order or null if failed
  }
}

final editJobScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<
        EditJobScreenController,
        Order?>(EditJobScreenController.new);
