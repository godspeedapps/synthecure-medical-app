import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsTotals {
  final Map<String, double> revenue;
  final Map<String, int> orders;
  final Map<String, int> productsSold;
  final Map<String, int> hospitals;
  final Map<String, int> doctors;
  final Map<String, double> averageOrderValue;

  final Map<String, double> previousRevenue;
  final Map<String, int> previousOrders;
  final Map<String, int> previousProductsSold;
  final Map<String, int> previousHospitals;
  final Map<String, int> previousDoctors;
  final Map<String, double> previousAverageOrderValue;

  AnalyticsTotals({
    required this.revenue,
    required this.orders,
    required this.productsSold,
    required this.hospitals,
    required this.doctors,
    required this.averageOrderValue,
    required this.previousRevenue,
    required this.previousOrders,
    required this.previousProductsSold,
    required this.previousHospitals,
    required this.previousDoctors,
    required this.previousAverageOrderValue,
  });

  factory AnalyticsTotals.fromFirestore(Map<String, dynamic> data) {
    return AnalyticsTotals(
      revenue: {
        "total": (data["totalRevenue"] ?? 0.0).toDouble(),
        "daily": (data["dailyRevenue"] ?? 0.0).toDouble(),
        "weekly": (data["weeklyRevenue"] ?? 0.0).toDouble(),
        "monthly": (data["monthlyRevenue"] ?? 0.0).toDouble(),
        "yearly": (data["yearlyRevenue"] ?? 0.0).toDouble(),
      },
      orders: {
        "total": data["totalOrders"] ?? 0,
        "daily": data["dailyOrders"] ?? 0,
        "weekly": data["weeklyOrders"] ?? 0,
        "monthly": data["monthlyOrders"] ?? 0,
        "yearly": data["yearlyOrders"] ?? 0,
      },
      productsSold: {
        "total": data["totalProductsSold"] ?? 0,
        "daily": data["dailyProductsSold"] ?? 0,
        "weekly": data["weeklyProductsSold"] ?? 0,
        "monthly": data["monthlyProductsSold"] ?? 0,
        "yearly": data["yearlyProductsSold"] ?? 0,
      },
      hospitals: {
        "total": data["totalHospitals"] ?? 0,
        "daily": data["dailyHospitals"] ?? 0,
        "weekly": data["weeklyHospitals"] ?? 0,
        "monthly": data["monthlyHospitals"] ?? 0,
        "yearly": data["yearlyHospitals"] ?? 0,
      },
      doctors: {
        "total": data["totalDoctors"] ?? 0,
        "daily": data["dailyDoctors"] ?? 0,
        "weekly": data["weeklyDoctors"] ?? 0,
        "monthly": data["monthlyDoctors"] ?? 0,
        "yearly": data["yearlyDoctors"] ?? 0,
      },
      averageOrderValue: {
        "total": (data["averageOrderValue"] ?? 0.0).toDouble(),
        "daily": (data["dailyAverageOrderValue"] ?? 0.0).toDouble(),
        "weekly": (data["weeklyAverageOrderValue"] ?? 0.0).toDouble(),
        "monthly": (data["monthlyAverageOrderValue"] ?? 0.0).toDouble(),
        "yearly": (data["yearlyAverageOrderValue"] ?? 0.0).toDouble(),
      },
      previousRevenue: {
        "total": (data["previousTotalRevenue"] ?? 0.0).toDouble(),
        "daily": (data["previousDailyRevenue"] ?? 0.0).toDouble(),
        "weekly": (data["previousWeeklyRevenue"] ?? 0.0).toDouble(),
        "monthly": (data["previousMonthlyRevenue"] ?? 0.0).toDouble(),
        "yearly": (data["previousYearlyRevenue"] ?? 0.0).toDouble(),
      },
      previousOrders: {
        "total": data["previousTotalOrders"] ?? 0,
        "daily": data["previousDailyOrders"] ?? 0,
        "weekly": data["previousWeeklyOrders"] ?? 0,
        "monthly": data["previousMonthlyOrders"] ?? 0,
        "yearly": data["previousYearlyOrders"] ?? 0,
      },
      previousProductsSold: {
        "total": data["previousTotalProductsSold"] ?? 0,
        "daily": data["previousDailyProductsSold"] ?? 0,
        "weekly": data["previousWeeklyProductsSold"] ?? 0,
        "monthly": data["previousMonthlyProductsSold"] ?? 0,
        "yearly": data["previousYearlyProductsSold"] ?? 0,
      },
      previousHospitals: {
        "total": data["previousTotalHospitals"] ?? 0,
        "daily": data["previousDailyHospitals"] ?? 0,
        "weekly": data["previousWeeklyHospitals"] ?? 0,
        "monthly": data["previousMonthlyHospitals"] ?? 0,
        "yearly": data["previousYearlyHospitals"] ?? 0,
      },
      previousDoctors: {
        "total": data["previousTotalDoctors"] ?? 0,
        "daily": data["previousDailyDoctors"] ?? 0,
        "weekly": data["previousWeeklyDoctors"] ?? 0,
        "monthly": data["previousMonthlyDoctors"] ?? 0,
        "yearly": data["previousYearlyDoctors"] ?? 0,
      },
      previousAverageOrderValue: {
        "total": (data["previousAverageOrderValue"] ?? 0.0).toDouble(),
        "daily": (data["previousDailyAverageOrderValue"] ?? 0.0).toDouble(),
        "weekly": (data["previousWeeklyAverageOrderValue"] ?? 0.0).toDouble(),
        "monthly": (data["previousMonthlyAverageOrderValue"] ?? 0.0).toDouble(),
        "yearly": (data["previousYearlyAverageOrderValue"] ?? 0.0).toDouble(),
      },
    );
  }

  double calculatePercentageChange(String period) {
    double current = revenue[period] ?? 0.0;
    double previous = previousRevenue[period] ?? 0.0;
    if (previous == 0.0) return 0.0;
    return ((current - previous) / previous) * 100;
  }
}


final testAnalyticsTotals = AnalyticsTotals(
  revenue: {
    "total": 520000.0,
    "daily": 5100.0,
    "weekly": 36500.0,
    "monthly": 155000.0,
    "yearly": 520000.0,
  },
  orders: {
    "total": 10200,
    "daily": 105,
    "weekly": 725,
    "monthly": 3050,
    "yearly": 10200,
  },
  productsSold: {
    "total": 51000,
    "daily": 520,
    "weekly": 3600,
    "monthly": 15500,
    "yearly": 51000,
  },
  hospitals: {
    "total": 105,
    "daily": 3,
    "weekly": 12,
    "monthly": 35,
    "yearly": 105,
  },
  doctors: {
    "total": 55,
    "daily": 2,
    "weekly": 7,
    "monthly": 20,
    "yearly": 55,
  },
  averageOrderValue: {
    "total": 51.5,
    "daily": 52.1,
    "weekly": 49.3,
    "monthly": 50.7,
    "yearly": 52.5,
  },
  previousRevenue: {
    "total": 505000.0,
    "daily": 4900.0,
    "weekly": 34500.0,
    "monthly": 145000.0,
    "yearly": 500000.0,
  },
  previousOrders: {
    "total": 9900,
    "daily": 187,
    "weekly": 890,
    "monthly": 2950,
    "yearly": 9900,
  },
  previousProductsSold: {
    "total": 49500,
    "daily": 500,
    "weekly": 3450,
    "monthly": 14900,
    "yearly": 49500,
  },
  previousHospitals: {
    "total": 100,
    "daily": 2,
    "weekly": 10,
    "monthly": 30,
    "yearly": 100,
  },
  previousDoctors: {
    "total": 50,
    "daily": 1,
    "weekly": 5,
    "monthly": 15,
    "yearly": 50,
  },
  previousAverageOrderValue: {
    "total": 48.9,
    "daily": 49.2,
    "weekly": 50.1,
    "monthly": 51.3,
    "yearly": 50.7,
  },
);
