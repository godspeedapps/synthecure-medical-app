// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$analyticsServiceHash() => r'bd0cfa7cdc26f0bc0812a1dac1955ff1398c913f';

/// See also [analyticsService].
@ProviderFor(analyticsService)
final analyticsServiceProvider = AutoDisposeProvider<AnalyticsService>.internal(
  analyticsService,
  name: r'analyticsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnalyticsServiceRef = AutoDisposeProviderRef<AnalyticsService>;
String _$salesOverviewStreamHash() =>
    r'ba6c2167eccff9411d0a2b08df28b639da532910';

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

/// See also [salesOverviewStream].
@ProviderFor(salesOverviewStream)
const salesOverviewStreamProvider = SalesOverviewStreamFamily();

/// See also [salesOverviewStream].
class SalesOverviewStreamFamily extends Family<AsyncValue<DashboardAnalytics>> {
  /// See also [salesOverviewStream].
  const SalesOverviewStreamFamily();

  /// See also [salesOverviewStream].
  SalesOverviewStreamProvider call({
    required String id,
    required String mode,
  }) {
    return SalesOverviewStreamProvider(
      id: id,
      mode: mode,
    );
  }

  @override
  SalesOverviewStreamProvider getProviderOverride(
    covariant SalesOverviewStreamProvider provider,
  ) {
    return call(
      id: provider.id,
      mode: provider.mode,
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
  String? get name => r'salesOverviewStreamProvider';
}

/// See also [salesOverviewStream].
class SalesOverviewStreamProvider extends FutureProvider<DashboardAnalytics> {
  /// See also [salesOverviewStream].
  SalesOverviewStreamProvider({
    required String id,
    required String mode,
  }) : this._internal(
          (ref) => salesOverviewStream(
            ref as SalesOverviewStreamRef,
            id: id,
            mode: mode,
          ),
          from: salesOverviewStreamProvider,
          name: r'salesOverviewStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$salesOverviewStreamHash,
          dependencies: SalesOverviewStreamFamily._dependencies,
          allTransitiveDependencies:
              SalesOverviewStreamFamily._allTransitiveDependencies,
          id: id,
          mode: mode,
        );

  SalesOverviewStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
    required this.mode,
  }) : super.internal();

  final String id;
  final String mode;

  @override
  Override overrideWith(
    FutureOr<DashboardAnalytics> Function(SalesOverviewStreamRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SalesOverviewStreamProvider._internal(
        (ref) => create(ref as SalesOverviewStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
        mode: mode,
      ),
    );
  }

  @override
  FutureProviderElement<DashboardAnalytics> createElement() {
    return _SalesOverviewStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SalesOverviewStreamProvider &&
        other.id == id &&
        other.mode == mode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SalesOverviewStreamRef on FutureProviderRef<DashboardAnalytics> {
  /// The parameter `id` of this provider.
  String get id;

  /// The parameter `mode` of this provider.
  String get mode;
}

class _SalesOverviewStreamProviderElement
    extends FutureProviderElement<DashboardAnalytics>
    with SalesOverviewStreamRef {
  _SalesOverviewStreamProviderElement(super.provider);

  @override
  String get id => (origin as SalesOverviewStreamProvider).id;
  @override
  String get mode => (origin as SalesOverviewStreamProvider).mode;
}

String _$monthlyAnalyticsStreamHash() =>
    r'a28d747a2931b4aa82bae37c388ab156fd84f16a';

/// See also [monthlyAnalyticsStream].
@ProviderFor(monthlyAnalyticsStream)
const monthlyAnalyticsStreamProvider = MonthlyAnalyticsStreamFamily();

/// See also [monthlyAnalyticsStream].
class MonthlyAnalyticsStreamFamily
    extends Family<AsyncValue<MonthlyAnalytics>> {
  /// See also [monthlyAnalyticsStream].
  const MonthlyAnalyticsStreamFamily();

  /// See also [monthlyAnalyticsStream].
  MonthlyAnalyticsStreamProvider call({
    required String id,
  }) {
    return MonthlyAnalyticsStreamProvider(
      id: id,
    );
  }

  @override
  MonthlyAnalyticsStreamProvider getProviderOverride(
    covariant MonthlyAnalyticsStreamProvider provider,
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
  String? get name => r'monthlyAnalyticsStreamProvider';
}

/// See also [monthlyAnalyticsStream].
class MonthlyAnalyticsStreamProvider extends StreamProvider<MonthlyAnalytics> {
  /// See also [monthlyAnalyticsStream].
  MonthlyAnalyticsStreamProvider({
    required String id,
  }) : this._internal(
          (ref) => monthlyAnalyticsStream(
            ref as MonthlyAnalyticsStreamRef,
            id: id,
          ),
          from: monthlyAnalyticsStreamProvider,
          name: r'monthlyAnalyticsStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monthlyAnalyticsStreamHash,
          dependencies: MonthlyAnalyticsStreamFamily._dependencies,
          allTransitiveDependencies:
              MonthlyAnalyticsStreamFamily._allTransitiveDependencies,
          id: id,
        );

  MonthlyAnalyticsStreamProvider._internal(
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
    Stream<MonthlyAnalytics> Function(MonthlyAnalyticsStreamRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyAnalyticsStreamProvider._internal(
        (ref) => create(ref as MonthlyAnalyticsStreamRef),
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
  StreamProviderElement<MonthlyAnalytics> createElement() {
    return _MonthlyAnalyticsStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyAnalyticsStreamProvider && other.id == id;
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
mixin MonthlyAnalyticsStreamRef on StreamProviderRef<MonthlyAnalytics> {
  /// The parameter `id` of this provider.
  String get id;
}

class _MonthlyAnalyticsStreamProviderElement
    extends StreamProviderElement<MonthlyAnalytics>
    with MonthlyAnalyticsStreamRef {
  _MonthlyAnalyticsStreamProviderElement(super.provider);

  @override
  String get id => (origin as MonthlyAnalyticsStreamProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
