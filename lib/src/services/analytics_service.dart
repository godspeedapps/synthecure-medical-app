import 'package:synthecure/src/domain/analytics_totals.dart';
import 'package:synthecure/src/domain/dashboard_analytics.dart';
import 'package:synthecure/src/domain/monthly_analytics.dart';
import 'package:synthecure/src/domain/sales_totals.dart';
import 'package:synthecure/src/features/admin/dashboard/sales_overview.dart';
import 'package:synthecure/src/repositories/analytics_repository.dart';
import 'package:synthecure/src/repositories/entries_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/firebase_auth_repository.dart';
import '../domain/app_user.dart';
import '../repositories/orders_repository.dart';
import '../domain/order.dart';

part 'analytics_service.g.dart';

class AnalyticsService {
  AnalyticsService({required this.analyticsRepository});

  final AnalyticsRepository analyticsRepository;

  Future<DashboardAnalytics> _salesOverviewStream(
          UserID uid, String period) =>
      analyticsRepository.fetchAnalytics(period);

  Stream<MonthlyAnalytics> _monthlyAnalyticsStream() =>
      analyticsRepository.watchMonthlyAnalytics().map(
          (monthlyData) => monthlyData.withComputedData());
}

@riverpod
// ignore: deprecated_member_use_from_same_package
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  return AnalyticsService(
      analyticsRepository:
          ref.watch(analyticsRepositoryProvider));
}

@Riverpod(keepAlive: true)
Future<DashboardAnalytics> salesOverviewStream(
  SalesOverviewStreamRef ref, {
  required String id, required String mode // Accept an id argument
}) {
  final user = ref.watch(firebaseAuthProvider).currentUser;

  if (user == null) {
    throw AssertionError('User can\'t be null');
  }

  final analyticsService =
      ref.watch(analyticsServiceProvider);

  return analyticsService._salesOverviewStream(id, mode);
}

@Riverpod(keepAlive: true)
Stream<MonthlyAnalytics> monthlyAnalyticsStream(
    MonthlyAnalyticsStreamRef ref,
    {required String id}) {
  final user = ref
      .read(firebaseAuthProvider)
      .currentUser; // ✅ Read instead of watch

  if (user == null) {
    throw AssertionError('User can\'t be null');
  }

  print("recalling monthly");

  final analyticsService = ref.read(
      analyticsServiceProvider); // ✅ Read instead of watch

  return analyticsService
      ._monthlyAnalyticsStream(); // ✅ Uses cached stream
}
