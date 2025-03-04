import 'package:synthecure/src/domain/order_detail.dart';

class DashboardAnalytics {
  final DateTime period;
  final double totalRevenue;
  final int totalOrders;
  final int totalProductsSold;
  final int totalCustomers;
  final int totalUsers; // ✅ Added totalUsers
  final int totalDoctors; // ✅ Added totalDoctors
  final double averageOrderValue; // ✅ Added AOV
  final double? percentChangeRevenue;
  final double? percentChangeOrders;
  final double? percentChangeProductsSold;
  final double? percentChangeCustomers;
  final double? percentChangeUsers; // ✅ Added percentChangeUsers
  final double? percentChangeDoctors; // ✅ Added percentChangeDoctors
  final double? percentChangeAOV; // ✅ Added percentChangeAOV
  final List<OrderDetail> orderDetails;

  // ✅ Empty constructor with default values
  DashboardAnalytics.empty()
      : period = DateTime.now(),
        totalRevenue = 0.0,
        totalOrders = 0,
        totalProductsSold = 0,
        totalCustomers = 0,
        totalUsers = 0,
        totalDoctors = 0,
        averageOrderValue = 0.0, // ✅ Default AOV
        percentChangeRevenue = null,
        percentChangeOrders = null,
        percentChangeProductsSold = null,
        percentChangeCustomers = null,
        percentChangeUsers = null,
        percentChangeDoctors = null,
        percentChangeAOV = null,
        orderDetails = [];

  DashboardAnalytics({
    required this.period,
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProductsSold,
    required this.totalCustomers,
    required this.totalUsers,
    required this.totalDoctors, // ✅ Added totalDoctors
    required this.averageOrderValue, // ✅ Added AOV
    this.percentChangeRevenue,
    this.percentChangeOrders,
    this.percentChangeProductsSold,
    this.percentChangeCustomers,
    this.percentChangeUsers,
    this.percentChangeDoctors, // ✅ Added percentChangeDoctors
    this.percentChangeAOV, // ✅ Added percentChangeAOV
    required this.orderDetails,
  });

  factory DashboardAnalytics.fromMap(Map<String, dynamic> data) {
    return DashboardAnalytics(
      period: DateTime.parse(data["period"]["value"]),
      totalRevenue: _parseDouble(data["totalRevenue"]) ?? 0.0,
      totalOrders: _parseInt(data["totalOrders"]),
      totalProductsSold: _parseInt(data["totalProductsSold"]),
      totalCustomers: _parseInt(data["totalCustomers"]),
      totalUsers: _parseInt(data["totalUsers"]),
      totalDoctors: _parseInt(data["totalDoctors"]), // ✅ Added totalDoctors
      averageOrderValue: _parseDouble(data["averageOrderValue"]) ?? 0.0, // ✅ Added AOV
      percentChangeRevenue: _parseDouble(data["percentChangeRevenue"]),
      percentChangeOrders: _parseDouble(data["percentChangeOrders"]),
      percentChangeProductsSold: _parseDouble(data["percentChangeProductsSold"]),
      percentChangeCustomers: _parseDouble(data["percentChangeCustomers"]),
      percentChangeUsers: _parseDouble(data["percentChangeUsers"]),
      percentChangeDoctors: _parseDouble(data["percentChangeDoctors"]), // ✅ Added percentChangeDoctors
      percentChangeAOV: _parseDouble(data["percentChangeAOV"]), // ✅ Added percentChangeAOV
      orderDetails: (data["orderDetails"] as List<dynamic>)
          .map((e) => OrderDetail.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
