import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/domain/order.dart'
    as model;
import 'package:synthecure/src/domain/sales_totals.dart';

import 'firebase_auth_repository.dart';
import '../domain/app_user.dart';

class AnalyticsRepository {
  const AnalyticsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  static String totalsPath = 'analytics/totals';

  /// Stream the analytics totals document from Firestore
  Stream<SalesTotals> streamTotals() {
    final totalsRef = _firestore.doc(totalsPath);

    return totalsRef.snapshots().map(
      (snapshot) => SalesTotals.fromFirestore(snapshot.data() ?? {}),
    );
  }
}


final analyticsRepositoryProvider =
    Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(FirebaseFirestore.instance);
});



