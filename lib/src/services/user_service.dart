import 'package:synthecure/src/repositories/firebase_auth_repository.dart';
import 'package:synthecure/src/repositories/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synthecure/src/domain/app_user.dart';

part 'user_service.g.dart';

class UserService {
  UserService({required this.userRepository});

  final UserRepository userRepository;

  /// Stream all users from Firestore
  Stream<List<AppUser>> watchAllUsers() {
    return userRepository.watchUsers().map(_sortUsers);
  }

  /// Stream specific user from Firestore
  Stream<AppUser> watchUser({required String id}) {
    return userRepository.streamUser(id);
  }

  /// Sort users alphabetically by name
  static List<AppUser> _sortUsers(List<AppUser> users) {
    // First, sort by whether the user is an admin (admin at the top)
    users.sort((a, b) {
      if (a.isAdmin && !b.isAdmin) {
        return -1; // 'a' comes first if 'a' is admin
      }
      if (!a.isAdmin && b.isAdmin) {
        return 1; // 'b' comes first if 'b' is admin
      }
      return a.lastName.compareTo(
          b.lastName); // Alphabetical order by last name
    });
    return users;
  }
}

@riverpod
UserService userService(UserServiceRef ref) {
  return UserService(
    userRepository: ref.watch(userRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
Stream<AppUser> userProvider(UserProviderRef ref, {
  required String id, // Accept an id argument
}) {

  final user = ref.watch(firebaseAuthProvider).currentUser;

  if (user == null) {
    throw AssertionError('User can\'t be null when fetching products');
  }

  final userService = ref.watch(userServiceProvider);
  return userService.watchUser(id: id);
}

@riverpod
Stream<List<AppUser>> allUsersStream(
    AllUsersStreamRef ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.watchAllUsers();
}
