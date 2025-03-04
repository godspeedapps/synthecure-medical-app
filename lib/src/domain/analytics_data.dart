import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsData {
  final double totalRevenue;
  final int totalOrders;
  final int totalProductsSold;
  final int totalHospitals;
  final int totalDoctors;
  final double averageOrderValue;
  final double percentChangeRevenue;
  final double percentChangeOrders;
  final double percentChangeProductsSold;
  final double percentChangeHospitals;
  final double percentChangeDoctors;
  final double percentChangeAverageOrderValue;

  AnalyticsData({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProductsSold,
    required this.totalHospitals,
    required this.totalDoctors,
    required this.averageOrderValue,
    required this.percentChangeRevenue,
    required this.percentChangeOrders,
    required this.percentChangeProductsSold,
    required this.percentChangeHospitals,
    required this.percentChangeDoctors,
    required this.percentChangeAverageOrderValue,
  });

  factory AnalyticsData.fromBigQuery(Map<String, dynamic> data) {
    return AnalyticsData(
      totalRevenue: (data["totalRevenue"] ?? 0.0).toDouble(),
      totalOrders: data["totalOrders"] ?? 0,
      totalProductsSold: data["totalProductsSold"] ?? 0,
      totalHospitals: data["totalHospitals"] ?? 0,
      totalDoctors: data["totalDoctors"] ?? 0,
      averageOrderValue: (data["averageOrderValue"] ?? 0.0).toDouble(),
      
      percentChangeRevenue: (data["percentChangeRevenue"] ?? 0.0).toDouble(),
      percentChangeOrders: (data["percentChangeOrders"] ?? 0.0).toDouble(),
      percentChangeProductsSold: (data["percentChangeProductsSold"] ?? 0.0).toDouble(),
      percentChangeHospitals: (data["percentChangeHospitals"] ?? 0.0).toDouble(),
      percentChangeDoctors: (data["percentChangeDoctors"] ?? 0.0).toDouble(),
      percentChangeAverageOrderValue: (data["percentChangeAverageOrderValue"] ?? 0.0).toDouble(),
    );
  }
}
