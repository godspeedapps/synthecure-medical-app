import 'package:synthecure/src/domain/sales_totals.dart';
import 'package:synthecure/src/repositories/analytics_repository.dart';
import 'package:synthecure/src/repositories/entries_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/firebase_auth_repository.dart';
import '../domain/app_user.dart';
import '../repositories/orders_repository.dart';
import '../domain/order.dart';

part 'analytics_service.g.dart';

class AnalyticsService {
  AnalyticsService(
      {required this.analyticsRepository});

  final AnalyticsRepository analyticsRepository;

  Stream<SalesTotals> _salesOverviewStream(UserID uid) =>
      analyticsRepository.streamTotals();


}

@riverpod
// ignore: deprecated_member_use_from_same_package
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  return AnalyticsService(
    analyticsRepository: ref.watch(analyticsRepositoryProvider)
  );
}

@riverpod
Stream<SalesTotals> salesOverviewStream(SalesOverviewStreamRef ref, {
  required String id, // Accept an id argument
}) {
  final user = ref.watch(firebaseAuthProvider).currentUser;

  if (user == null) {
    throw AssertionError('User can\'t be null');
  }

  final analyticsService = ref.watch(analyticsServiceProvider);

  return analyticsService._salesOverviewStream(id);
}
