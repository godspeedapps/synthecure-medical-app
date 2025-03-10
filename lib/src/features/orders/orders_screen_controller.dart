import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/features/admin/dashboard/sales_overview.dart';
import 'package:synthecure/src/services/analytics_service.dart';

import '../../repositories/firebase_auth_repository.dart';
import '../../repositories/orders_repository.dart';
import '../../domain/order.dart';

class OrderScreenController
    extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<bool> deleteOrder(Order order) async {
    final currentUser =
        ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }
    final repository = ref.read(ordersRepositoryProvider);
    state = const AsyncLoading();

    await Future.delayed(const Duration(seconds: 1));

    state = await AsyncValue.guard(() =>
        repository.deleteJob(
            uid: order.createdBy,
            orderId: order.id,
            hospitalId: order.hospital.id,
            doctorId: order.doctor.id));

    // ignore: unused_result

    Future.delayed(
        Duration(seconds: 2),
        () => ref.refresh(salesOverviewStreamProvider(
            id: ref
                .read(firebaseAuthProvider)
                .currentUser!
                .uid,
            mode: ref.read(selectedTimePeriodProvider))));

    return !state.hasError;
  }
}

final orderScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<OrderScreenController,
        void>(OrderScreenController.new);
