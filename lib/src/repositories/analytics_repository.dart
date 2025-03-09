import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:synthecure/src/domain/analytics_totals.dart';
import 'package:synthecure/src/domain/dashboard_analytics.dart';
import 'package:synthecure/src/domain/monthly_analytics.dart';
import 'package:synthecure/src/domain/order.dart' as model;
import 'package:synthecure/src/domain/sales_totals.dart';

import 'firebase_auth_repository.dart';
import '../domain/app_user.dart';
import 'package:rxdart/rxdart.dart';

class AnalyticsRepository {
  const AnalyticsRepository(
      this._firestore, this.functions);
  final FirebaseFirestore _firestore;

  final FirebaseFunctions functions;

  static String totalsPath = 'analytics/totals';
  static String monthlyPath(String year, String month) =>
      'analytics/yearly_$year/monthly/$month';

  static String ordersPath(String year, String month) =>
      'analytics/yearly_$year/monthly/$month/orders';

  static String getCurrentYear() =>
      DateTime.now().year.toString();

  String getCurrentMonthFormatted() {
    return DateFormat('yyyy-MM').format(DateTime.now());
  }

  /// Stream the analytics totals document from Firestore
  Stream<AnalyticsTotals> streamTotals() {
    print("Streaming totals");
    final totalsRef = _firestore.doc(totalsPath);

    return totalsRef.snapshots().map(
          (snapshot) => AnalyticsTotals.fromFirestore(
              snapshot.data() ?? {}),
        );
  }

  // 🔥 Watch Monthly Analytics & Orders in Real Time
  Stream<MonthlyAnalytics> watchMonthlyAnalytics() {
    print("getting omonthly");

    String year = getCurrentYear();
    String month = getCurrentMonthFormatted();

    final monthlyStream = _firestore
        .doc(monthlyPath(year, month))
        .snapshots();

    final ordersStream = _firestore
        .collection(ordersPath(year, month))
        .orderBy('orderDate',
            descending:
                false) // ✅ Sorts by date (earliest to latest)
        .snapshots();

    return Rx.combineLatest2(
      monthlyStream,
      ordersStream,
      (DocumentSnapshot monthlySnapshot,
          QuerySnapshot ordersSnapshot) {
        final orders = ordersSnapshot.docs
            .map((doc) => OrderAnalytics.fromFirestore(doc))
            .toList();

        return MonthlyAnalytics.fromFirestore(
            monthlySnapshot, orders);
      },
    );
  }

  Future<DashboardAnalytics> fetchAnalytics(
      String period) async {
    try {
      final HttpsCallable callable =
          functions.httpsCallable("getAnalyticsByPeriod");
      final HttpsCallableResult result =
          await callable.call({"period": period});

      if (result.data["success"] == true) {
     

        // ✅ Ensure correct casting of BigQuery response
        List<DashboardAnalytics> analyticsList = (result
                .data["data"] as List<dynamic>)
            .map((e) => DashboardAnalytics.fromMap(
                Map<String, dynamic>.from(
                    e))) // ✅ Explicitly convert each entry
            .toList();

        return analyticsList.first;
      } else {
        throw Exception("No analytics data found.");
      }
    } catch (e) {
      print("❌ Error fetching analytics: $e");
      return DashboardAnalytics.empty();
    }
  }
}

final analyticsRepositoryProvider =
    Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(FirebaseFirestore.instance,  FirebaseFunctions.instance);
});
