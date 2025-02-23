import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/routing/app_router.dart';
import '../../../repositories/firebase_auth_repository.dart';
import 'email_password_sign_in_form_type.dart';

class EmailPasswordSignInController
    extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> submit(
      {required String email,
      required String password,
      required EmailPasswordSignInFormType
          formType}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _authenticate(email, password, formType));
  }

  Future<void> reset({required String email}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _reset(email));
  }

  Future<void> _reset(String email) async {
    final authRepository = ref.read(authRepositoryProvider);

    await authRepository.passwordReset(email);
  }

  Future<void> _authenticate(String email, String password,
      EmailPasswordSignInFormType formType) async {
    final authRepository = ref.read(authRepositoryProvider);

    await authRepository.signInWithEmailAndPassword(
        email, password);

    await ref.read(isAdminProvider.notifier).checkIsAdmin();
  }
}

final emailPasswordSignInControllerProvider =
    AutoDisposeAsyncNotifierProvider<
        EmailPasswordSignInController,
        void>(EmailPasswordSignInController.new);
