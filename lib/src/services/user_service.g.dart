// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userServiceHash() => r'96152b01f348387ef2e4f2d0c8195227c1deb96d';

/// See also [userService].
@ProviderFor(userService)
final userServiceProvider = AutoDisposeProvider<UserService>.internal(
  userService,
  name: r'userServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserServiceRef = AutoDisposeProviderRef<UserService>;
String _$userProviderHash() => r'a8fab93753976f9f185ebf5121f0b6288ad44000';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [userProvider].
@ProviderFor(userProvider)
const userProviderProvider = UserProviderFamily();

/// See also [userProvider].
class UserProviderFamily extends Family<AsyncValue<AppUser>> {
  /// See also [userProvider].
  const UserProviderFamily();

  /// See also [userProvider].
  UserProviderProvider call({
    required String id,
  }) {
    return UserProviderProvider(
      id: id,
    );
  }

  @override
  UserProviderProvider getProviderOverride(
    covariant UserProviderProvider provider,
  ) {
    return call(
      id: provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userProviderProvider';
}

/// See also [userProvider].
class UserProviderProvider extends StreamProvider<AppUser> {
  /// See also [userProvider].
  UserProviderProvider({
    required String id,
  }) : this._internal(
          (ref) => userProvider(
            ref as UserProviderRef,
            id: id,
          ),
          from: userProviderProvider,
          name: r'userProviderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userProviderHash,
          dependencies: UserProviderFamily._dependencies,
          allTransitiveDependencies:
              UserProviderFamily._allTransitiveDependencies,
          id: id,
        );

  UserProviderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    Stream<AppUser> Function(UserProviderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserProviderProvider._internal(
        (ref) => create(ref as UserProviderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  StreamProviderElement<AppUser> createElement() {
    return _UserProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProviderProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserProviderRef on StreamProviderRef<AppUser> {
  /// The parameter `id` of this provider.
  String get id;
}

class _UserProviderProviderElement extends StreamProviderElement<AppUser>
    with UserProviderRef {
  _UserProviderProviderElement(super.provider);

  @override
  String get id => (origin as UserProviderProvider).id;
}

String _$allUsersStreamHash() => r'82b5cbdafea7257ab594c10d73682201d94dab9e';

/// See also [allUsersStream].
@ProviderFor(allUsersStream)
final allUsersStreamProvider =
    AutoDisposeStreamProvider<List<AppUser>>.internal(
  allUsersStream,
  name: r'allUsersStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allUsersStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllUsersStreamRef = AutoDisposeStreamProviderRef<List<AppUser>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
