import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyAnalytics {
  final double averageOrderValue;
  final int totalOrders;
  final int totalProductsSold;
  final double totalRevenue;
  final List<OrderAnalytics> orderAnalytics;

  // 🔥 Computed Fields for Daily, Weekly, and Monthly
  late final List<FlSpot> dailyRevenueSpots;
  late final List<BarChartGroupData> weeklyBarData;
  late final List<FlSpot> monthlyRevenueSpots;

  // 🔥 Store Orders Grouped by Day & Week
  final Map<String, List<OrderAnalytics>> dailyOrders;
  final Map<int, List<OrderAnalytics>> weeklyOrders;
  final List<OrderAnalytics> currentDayOrders;

  // 🔥 Revenue Calculations
  final double dailyRevenue;
  final double weeklyRevenue;

  // 🔥 Previous Analytics Data from Firebase Function
  final double previousDayRevenue;
  final double previousWeekRevenue;
  final double previousMonthRevenue;
  final double previousYearRevenue;

  final double latestRevenue;
  final double lastSheetRevenue;
  final double percentChange;

  MonthlyAnalytics({
    required this.averageOrderValue,
    required this.totalOrders,
    required this.totalProductsSold,
    required this.totalRevenue,
    required this.orderAnalytics,
    List<FlSpot>? dailyRevenueSpots,
    List<BarChartGroupData>? weeklyBarData,
    List<FlSpot>? monthlyRevenueSpots,
    this.dailyOrders = const {},
    this.weeklyOrders = const {},
    this.currentDayOrders = const [],
    this.dailyRevenue = 0.0,
    this.weeklyRevenue = 0.0,
    this.previousDayRevenue = 0.0,
    this.previousWeekRevenue = 0.0,
    this.previousMonthRevenue = 0.0,
    this.previousYearRevenue = 0.0,
    this.latestRevenue = 0.0,
    this.lastSheetRevenue = 0.0,
    this.percentChange = 0.0,
  }) {
    // ✅ Ensure FLChart always has data (Flat line if empty)
    this.dailyRevenueSpots = (dailyRevenueSpots == null ||
            dailyRevenueSpots.isEmpty)
        ? List.generate(
            10,
            (index) =>
                FlSpot(index.toDouble(), 0)) // ✅ Flat line
        : dailyRevenueSpots;

   this.weeklyBarData = (weeklyBarData == null || weeklyBarData.isEmpty)
    ? List.generate(
        7,
        (index) => BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: 0, // ✅ Keeps empty state
              width: 14,
              borderRadius: BorderRadius.circular(6),
              color: Colors.deepPurpleAccent.withOpacity(0.3),
            ),
          ],
        ),
      ) // ✅ Flat bars when no data
    : weeklyBarData;

    this.monthlyRevenueSpots = (monthlyRevenueSpots ==
                null ||
            monthlyRevenueSpots.isEmpty)
        ? List.generate(
            3,
            (index) =>
                FlSpot(index.toDouble(), 0)) // ✅ Flat line
        : monthlyRevenueSpots;
  }

  /// 🔥 Factory to convert Firestore data while keeping it intact
  factory MonthlyAnalytics.fromFirestore(
      DocumentSnapshot doc, List<OrderAnalytics> orders) {
    Map<String, dynamic> data =
        doc.data() as Map<String, dynamic>? ?? {};

    return MonthlyAnalytics(
      averageOrderValue:
          (data['averageOrderValue'] ?? 0).toDouble(),
      totalOrders: data['totalOrders'] ?? 0,
      totalProductsSold: data['totalProductsSold'] ?? 0,
      totalRevenue: (data['totalRevenue'] ?? 0).toDouble(),
      previousDayRevenue:
          (data['previousTotalRevenue'] ?? 0).toDouble(),
      previousWeekRevenue:
          (data['previousWeekRevenue'] ?? 0).toDouble(),
      previousMonthRevenue:
          (data['previousMonthRevenue'] ?? 0).toDouble(),
      previousYearRevenue:
          (data['previousYearRevenue'] ?? 0).toDouble(),
      orderAnalytics: orders,
    );
  }


 MonthlyAnalytics withComputedData() {
  // ✅ Ensure orders are sorted by date before processing
  final monthlyData = List<OrderAnalytics>.from(orderAnalytics)
    ..sort((a, b) => a.orderDate.compareTo(b.orderDate));

  // ✅ Handle case where there are no orders to prevent crashes
  if (monthlyData.isEmpty) {
    return MonthlyAnalytics(
      averageOrderValue: 0.0,
      totalOrders: 0,
      totalProductsSold: 0,
      totalRevenue: 0.0,
      orderAnalytics: [],
      previousDayRevenue: previousDayRevenue,
      previousWeekRevenue: previousWeekRevenue,
      previousMonthRevenue: previousMonthRevenue,
      previousYearRevenue: previousYearRevenue,
    );
  }

  // ✅ Initialize maps for revenue tracking
  Map<String, List<OrderAnalytics>> dailyOrders = {};  
  Map<int, double> weeklyRevenueMap = {};   
  List<OrderAnalytics> currentDayOrders = [];

  DateTime now = DateTime.now();
  String todayKey = DateFormat('yyyy-MM-dd').format(now);
  
  // ✅ Get the start and end of the current week (Monday-Sunday)
  DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

  for (var order in monthlyData) {
    String dayKey = DateFormat('yyyy-MM-dd').format(order.orderDate);

    // 🔥 Group orders by day
    dailyOrders.putIfAbsent(dayKey, () => []).add(order);

    // 🔥 Group revenue by weekday **ONLY FOR CURRENT WEEK**
    if (order.orderDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
        order.orderDate.isBefore(endOfWeek.add(Duration(days: 1)))) {
      int weekDayIndex = order.orderDate.weekday; // 1 = Monday, 7 = Sunday
      weeklyRevenueMap.update(weekDayIndex, (value) => value + order.total, ifAbsent: () => order.total);
    }

    // 🔥 Collect orders for today
    if (dayKey == todayKey) {
      currentDayOrders.add(order);
    }
  }

  // ✅ Compute Weekly Bar Data (Ensures 7 Days Are Always Present)
  List<BarChartGroupData> weeklyBarData = [];
  for (int i = 1; i <= 7; i++) { // Monday to Sunday (1-7)
    double totalRevenue = weeklyRevenueMap.containsKey(i) ? weeklyRevenueMap[i]! : 0;
    weeklyBarData.add(
      BarChartGroupData(
        x: i - 1, // ✅ Ensure X-values range from (0-6) for Monday-Sunday
        barRods: [
          BarChartRodData(
            toY: totalRevenue, // ✅ Y-Value is the total revenue for that day
            width: 14,
            borderRadius: BorderRadius.circular(6),
            color: Colors.deepPurpleAccent,
          ),
        ],
        showingTooltipIndicators: [0],
      ),
    );
  }

  // ✅ Compute Monthly Revenue Spots (Increasing X)
  List<FlSpot> monthlyRevenueSpots = [];
  int monthlyIndex = 0;
  dailyOrders.forEach((date, orders) {
    double totalRevenue = orders.fold(0, (sum, order) => sum + order.total);
    monthlyRevenueSpots.add(FlSpot(monthlyIndex.toDouble(), totalRevenue));
    monthlyIndex++;
  });

  // ✅ Compute Current Day Revenue Spots (Increasing X)
  List<FlSpot> currentDayRevenueSpots = [];
  for (int i = 0; i < currentDayOrders.length; i++) {
    currentDayRevenueSpots.add(FlSpot(i.toDouble(), currentDayOrders[i].total));
  }

  // ✅ Compute latest & last revenue
  double latestRevenue = monthlyRevenueSpots.isNotEmpty ? monthlyRevenueSpots.last.y : 0;
  double lastSheetRevenue = monthlyRevenueSpots.length > 1 ? monthlyRevenueSpots[monthlyRevenueSpots.length - 2].y : 0;

  // ✅ Compute percent change safely
  double percentChange = lastSheetRevenue == 0
      ? (latestRevenue != 0 ? 100 : 0)
      : ((latestRevenue - lastSheetRevenue) / lastSheetRevenue) * 100;

  return MonthlyAnalytics(
    averageOrderValue: totalOrders > 0 ? totalRevenue / totalOrders : 0.0,
    totalOrders: totalOrders,
    totalProductsSold: totalProductsSold,
    totalRevenue: totalRevenue,
    orderAnalytics: orderAnalytics,
    dailyRevenueSpots: currentDayRevenueSpots,
    weeklyBarData: weeklyBarData, // ✅ Now properly computed
    monthlyRevenueSpots: monthlyRevenueSpots,
    dailyOrders: dailyOrders,
    weeklyOrders: {}, // ✅ No longer needed
    currentDayOrders: currentDayOrders,
    dailyRevenue: currentDayRevenueSpots.fold(0, (sum, spot) => sum + spot.y),
    weeklyRevenue: weeklyBarData.fold(0, (sum, bar) => sum + bar.barRods[0].toY),
    previousDayRevenue: previousDayRevenue,
    previousWeekRevenue: previousWeekRevenue,
    previousMonthRevenue: previousMonthRevenue,
    previousYearRevenue: previousYearRevenue,
    latestRevenue: latestRevenue,
    lastSheetRevenue: lastSheetRevenue,
    percentChange: percentChange,
  );
}
}

/// 🔥 OrderAnalytics Model (No Changes)
class OrderAnalytics {
  final String orderId;
  final DateTime orderDate;
  final double total;

  OrderAnalytics({
    required this.orderId,
    required this.orderDate,
    required this.total,
  });

  factory OrderAnalytics.fromFirestore(
      DocumentSnapshot doc) {
    Map<String, dynamic> data =
        doc.data() as Map<String, dynamic>;

    return OrderAnalytics(
      orderId: doc.id,
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      total: (data['total'] ?? 0).toDouble(),
    );
  }
}

List<OrderAnalytics> mockOrders = [
  // Week 1 (Feb 1 - Feb 7)
  OrderAnalytics(
      orderId: "001",
      orderDate: DateTime(2025, 2, 1),
      total: 250),
  OrderAnalytics(
      orderId: "002",
      orderDate: DateTime(2025, 2, 3),
      total: 450),
  OrderAnalytics(
      orderId: "003",
      orderDate: DateTime(2025, 2, 6),
      total: 300),

  // Week 2 (Feb 8 - Feb 14)
  OrderAnalytics(
      orderId: "004",
      orderDate: DateTime(2025, 2, 8),
      total: 500),
  OrderAnalytics(
      orderId: "005",
      orderDate: DateTime(2025, 2, 10),
      total: 350),
  OrderAnalytics(
      orderId: "006",
      orderDate: DateTime(2025, 2, 12),
      total: 650),

  // Week 3 (Feb 15 - Feb 21)
  OrderAnalytics(
      orderId: "007",
      orderDate: DateTime(2025, 2, 15),
      total: 700),
  OrderAnalytics(
      orderId: "008",
      orderDate: DateTime(2025, 2, 17),
      total: 600),
  OrderAnalytics(
      orderId: "009",
      orderDate: DateTime(2025, 2, 19),
      total: 800),

  // Week 4 (Feb 22 - Feb 28)
  OrderAnalytics(
      orderId: "010",
      orderDate: DateTime(2025, 2, 22),
      total: 900),
  OrderAnalytics(
      orderId: "011",
      orderDate: DateTime(2025, 2, 24),
      total: 750),
  OrderAnalytics(
      orderId: "012",
      orderDate: DateTime(2025, 2, 27),
      total: 850),
];

// ✅ Create Mock MonthlyAnalytics for February 2025
MonthlyAnalytics mockAnalytics = MonthlyAnalytics(
  averageOrderValue: mockOrders.fold(
          0, (sum, order) => sum + order.total.toInt()) /
      mockOrders.length,
  totalOrders: mockOrders.length,
  totalProductsSold: mockOrders.length,
  totalRevenue:
      mockOrders.fold(0, (sum, order) => sum + order.total),
  orderAnalytics: mockOrders,
  previousDayRevenue:
      450, // Simulated previous day's revenue
  previousWeekRevenue:
      2000, // Simulated previous week's revenue
  previousMonthRevenue:
      18000, // Simulated previous month's revenue
  previousYearRevenue:
      200000, // Simulated previous year's revenue
).withComputedData();
