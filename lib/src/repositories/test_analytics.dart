import 'package:cloud_functions/cloud_functions.dart';
import 'package:synthecure/src/domain/dashboard_analytics.dart';


class FirebaseAnalyticsService {
  final FirebaseFunctions functions = FirebaseFunctions.instance;

  Future<List<DashboardAnalytics>> fetchAnalytics(String period) async {
    try {
      final HttpsCallable callable =
          functions.httpsCallable("getAnalyticsByPeriod");
      final HttpsCallableResult result =
          await callable.call({"period": period});

      if (result.data["success"] == true) {
        print("📊 Raw API Response: ${result.data["data"]}");

        // ✅ Ensure correct casting of BigQuery response
        List<DashboardAnalytics> analyticsList = (result.data["data"] as List<dynamic>)
            .map((e) => DashboardAnalytics.fromMap(Map<String, dynamic>.from(e))) // ✅ Explicitly convert each entry
            .toList();

        return analyticsList;
      } else {
        throw Exception("No analytics data found.");
      }
    } catch (e) {
      print("❌ Error fetching analytics: $e");
      return [];
    }
  }
}
