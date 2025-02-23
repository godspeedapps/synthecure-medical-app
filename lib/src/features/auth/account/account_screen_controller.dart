import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';
import 'package:synthecure/src/routing/app_router.dart';

class AccountScreenController
    extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> signOut() async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();

    await Future.delayed(Duration(seconds: 1));
    state = await AsyncValue.guard(authRepository.signOut);

    ref.read(isAdminProvider.notifier).reset();
  }
}

final accountScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<
        AccountScreenController,
        void>(AccountScreenController.new);
