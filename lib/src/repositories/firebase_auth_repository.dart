import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synthecure/src/domain/app_user.dart';
import 'package:synthecure/src/repositories/firebase_app_user.dart';
import 'package:synthecure/src/routing/app_router.dart';

part 'firebase_auth_repository.g.dart';

class AuthRepository {
  AuthRepository(this._auth, this.ref);
  final FirebaseAuth _auth;
  final Ref ref;

  static String userPath = 'users/';

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out).
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(_convertUser);
  }

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out) and also token refresh events.
  Stream<AppUser?> idTokenChanges() {
    return _auth.idTokenChanges().map(_convertUser);
  }

  AppUser? get currentUser =>
      _convertUser(_auth.currentUser);

  /// Helper method to convert a [User] to an [AppUser]
  AppUser? _convertUser(User? user) =>
      user != null ? FirebaseAppUser(user) : null;

  Future<void> signInAnonymously() {
    return _auth.signInAnonymously();
  }

  Future<void> signInWithEmailAndPassword(
      String email, String password) {
    return _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<bool> getIsAdmin() async {
    final user = _auth.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult();
      final isAdmin =
          idTokenResult.claims?['admin'] ?? false;
      return isAdmin;
    }
    return false;
  }

  Future<void> passwordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() {

    return _auth.signOut();
  }
}

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authRepositoryProvider =
    Provider<AuthRepository>((ref) {
  return AuthRepository(
      ref.watch(firebaseAuthProvider), ref);
});

// * Using keepAlive since other providers need it to be an
// * [AlwaysAliveProviderListenable]
@Riverpod(keepAlive: true)
Stream<AppUser?> authStateChanges(Ref ref) {
  print("AUTH STATE CHANGES!");
  final authRepository = ref.watch(authRepositoryProvider);
  final refresh = ref.refresh(isAdminProvider);
  return authRepository.authStateChanges();
}

@Riverpod(keepAlive: true)
Stream<AppUser?> idTokenChanges(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.idTokenChanges();
}

@riverpod
FutureOr<bool> isCurrentUserAdmin(Ref ref) {
  final user = ref.watch(idTokenChangesProvider).value;
  if (user != null) {
    return user.getIsAdmin();
  } else {
    return false;
  }
}
