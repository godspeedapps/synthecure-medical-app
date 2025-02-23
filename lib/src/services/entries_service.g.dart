// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entries_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$entriesServiceHash() => r'1f857d8b008d27697de9f5b1dab21cac42f26eaf';

/// See also [entriesService].
@ProviderFor(entriesService)
final entriesServiceProvider = AutoDisposeProvider<EntriesService>.internal(
  entriesService,
  name: r'entriesServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$entriesServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EntriesServiceRef = AutoDisposeProviderRef<EntriesService>;
String _$entriesTileModelStreamHash() =>
    r'1a64c85a988721325938e6e8cd4a4b50fbfa3d55';

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

/// See also [entriesTileModelStream].
@ProviderFor(entriesTileModelStream)
const entriesTileModelStreamProvider = EntriesTileModelStreamFamily();

/// See also [entriesTileModelStream].
class EntriesTileModelStreamFamily extends Family<AsyncValue<List<Order>>> {
  /// See also [entriesTileModelStream].
  const EntriesTileModelStreamFamily();

  /// See also [entriesTileModelStream].
  EntriesTileModelStreamProvider call({
    required String id,
  }) {
    return EntriesTileModelStreamProvider(
      id: id,
    );
  }

  @override
  EntriesTileModelStreamProvider getProviderOverride(
    covariant EntriesTileModelStreamProvider provider,
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
  String? get name => r'entriesTileModelStreamProvider';
}

/// See also [entriesTileModelStream].
class EntriesTileModelStreamProvider
    extends AutoDisposeStreamProvider<List<Order>> {
  /// See also [entriesTileModelStream].
  EntriesTileModelStreamProvider({
    required String id,
  }) : this._internal(
          (ref) => entriesTileModelStream(
            ref as EntriesTileModelStreamRef,
            id: id,
          ),
          from: entriesTileModelStreamProvider,
          name: r'entriesTileModelStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$entriesTileModelStreamHash,
          dependencies: EntriesTileModelStreamFamily._dependencies,
          allTransitiveDependencies:
              EntriesTileModelStreamFamily._allTransitiveDependencies,
          id: id,
        );

  EntriesTileModelStreamProvider._internal(
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
    Stream<List<Order>> Function(EntriesTileModelStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EntriesTileModelStreamProvider._internal(
        (ref) => create(ref as EntriesTileModelStreamRef),
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
  AutoDisposeStreamProviderElement<List<Order>> createElement() {
    return _EntriesTileModelStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EntriesTileModelStreamProvider && other.id == id;
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
mixin EntriesTileModelStreamRef on AutoDisposeStreamProviderRef<List<Order>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _EntriesTileModelStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<Order>>
    with EntriesTileModelStreamRef {
  _EntriesTileModelStreamProviderElement(super.provider);

  @override
  String get id => (origin as EntriesTileModelStreamProvider).id;
}

String _$adminEntriesStreamHash() =>
    r'bb123e8a025b28c93afeede527ec7473201a02cb';

/// See also [adminEntriesStream].
@ProviderFor(adminEntriesStream)
final adminEntriesStreamProvider =
    AutoDisposeStreamProvider<List<Order>>.internal(
  adminEntriesStream,
  name: r'adminEntriesStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminEntriesStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminEntriesStreamRef = AutoDisposeStreamProviderRef<List<Order>>;
String _$adminHospitalEntriesStreamHash() =>
    r'0ee0c13d5580571eddfef1a04625a9a09abade91';

/// See also [adminHospitalEntriesStream].
@ProviderFor(adminHospitalEntriesStream)
const adminHospitalEntriesStreamProvider = AdminHospitalEntriesStreamFamily();

/// See also [adminHospitalEntriesStream].
class AdminHospitalEntriesStreamFamily extends Family<AsyncValue<List<Order>>> {
  /// See also [adminHospitalEntriesStream].
  const AdminHospitalEntriesStreamFamily();

  /// See also [adminHospitalEntriesStream].
  AdminHospitalEntriesStreamProvider call({
    required String id,
  }) {
    return AdminHospitalEntriesStreamProvider(
      id: id,
    );
  }

  @override
  AdminHospitalEntriesStreamProvider getProviderOverride(
    covariant AdminHospitalEntriesStreamProvider provider,
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
  String? get name => r'adminHospitalEntriesStreamProvider';
}

/// See also [adminHospitalEntriesStream].
class AdminHospitalEntriesStreamProvider
    extends AutoDisposeStreamProvider<List<Order>> {
  /// See also [adminHospitalEntriesStream].
  AdminHospitalEntriesStreamProvider({
    required String id,
  }) : this._internal(
          (ref) => adminHospitalEntriesStream(
            ref as AdminHospitalEntriesStreamRef,
            id: id,
          ),
          from: adminHospitalEntriesStreamProvider,
          name: r'adminHospitalEntriesStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminHospitalEntriesStreamHash,
          dependencies: AdminHospitalEntriesStreamFamily._dependencies,
          allTransitiveDependencies:
              AdminHospitalEntriesStreamFamily._allTransitiveDependencies,
          id: id,
        );

  AdminHospitalEntriesStreamProvider._internal(
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
    Stream<List<Order>> Function(AdminHospitalEntriesStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminHospitalEntriesStreamProvider._internal(
        (ref) => create(ref as AdminHospitalEntriesStreamRef),
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
  AutoDisposeStreamProviderElement<List<Order>> createElement() {
    return _AdminHospitalEntriesStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminHospitalEntriesStreamProvider && other.id == id;
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
mixin AdminHospitalEntriesStreamRef
    on AutoDisposeStreamProviderRef<List<Order>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AdminHospitalEntriesStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<Order>>
    with AdminHospitalEntriesStreamRef {
  _AdminHospitalEntriesStreamProviderElement(super.provider);

  @override
  String get id => (origin as AdminHospitalEntriesStreamProvider).id;
}

String _$adminDoctorEntriesStreamHash() =>
    r'0ca7214246d5842536bc2e7ef9c26480a2b30404';

/// See also [adminDoctorEntriesStream].
@ProviderFor(adminDoctorEntriesStream)
const adminDoctorEntriesStreamProvider = AdminDoctorEntriesStreamFamily();

/// See also [adminDoctorEntriesStream].
class AdminDoctorEntriesStreamFamily extends Family<AsyncValue<List<Order>>> {
  /// See also [adminDoctorEntriesStream].
  const AdminDoctorEntriesStreamFamily();

  /// See also [adminDoctorEntriesStream].
  AdminDoctorEntriesStreamProvider call({
    required String id,
  }) {
    return AdminDoctorEntriesStreamProvider(
      id: id,
    );
  }

  @override
  AdminDoctorEntriesStreamProvider getProviderOverride(
    covariant AdminDoctorEntriesStreamProvider provider,
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
  String? get name => r'adminDoctorEntriesStreamProvider';
}

/// See also [adminDoctorEntriesStream].
class AdminDoctorEntriesStreamProvider
    extends AutoDisposeStreamProvider<List<Order>> {
  /// See also [adminDoctorEntriesStream].
  AdminDoctorEntriesStreamProvider({
    required String id,
  }) : this._internal(
          (ref) => adminDoctorEntriesStream(
            ref as AdminDoctorEntriesStreamRef,
            id: id,
          ),
          from: adminDoctorEntriesStreamProvider,
          name: r'adminDoctorEntriesStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminDoctorEntriesStreamHash,
          dependencies: AdminDoctorEntriesStreamFamily._dependencies,
          allTransitiveDependencies:
              AdminDoctorEntriesStreamFamily._allTransitiveDependencies,
          id: id,
        );

  AdminDoctorEntriesStreamProvider._internal(
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
    Stream<List<Order>> Function(AdminDoctorEntriesStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminDoctorEntriesStreamProvider._internal(
        (ref) => create(ref as AdminDoctorEntriesStreamRef),
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
  AutoDisposeStreamProviderElement<List<Order>> createElement() {
    return _AdminDoctorEntriesStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminDoctorEntriesStreamProvider && other.id == id;
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
mixin AdminDoctorEntriesStreamRef on AutoDisposeStreamProviderRef<List<Order>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AdminDoctorEntriesStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<Order>>
    with AdminDoctorEntriesStreamRef {
  _AdminDoctorEntriesStreamProviderElement(super.provider);

  @override
  String get id => (origin as AdminDoctorEntriesStreamProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
