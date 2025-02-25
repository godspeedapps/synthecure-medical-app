class SalesTotals {
  final double averageOrderValue;
  final double previousAverageOrderValue;
  final int previousTotalHospitals;
  final int previousTotalOrders;
  final int previousTotalProductsSold;
  final double previousTotalRevenue;
  final int totalHospitals;
  final int totalOrders;
  final int totalProductsSold;
  final double totalRevenue;

  SalesTotals({
    required this.averageOrderValue,
    required this.previousAverageOrderValue,
    required this.previousTotalHospitals,
    required this.previousTotalOrders,
    required this.previousTotalProductsSold,
    required this.previousTotalRevenue,
    required this.totalHospitals,
    required this.totalOrders,
    required this.totalProductsSold,
    required this.totalRevenue,
  });

  factory SalesTotals.fromFirestore(
      Map<String, dynamic> data) {
    return SalesTotals(
      averageOrderValue:
          (data['averageOrderValue'] ?? 0).toDouble(),
      previousAverageOrderValue:
          (data['previousAverageOrderValue'] ?? 0)
              .toDouble(),
      previousTotalHospitals:
          data['previousTotalHospitals'] ?? 0,
      previousTotalOrders: data['previousTotalOrders'] ?? 0,
      previousTotalProductsSold:
          data['previousTotalProductsSold'] ?? 0,
      previousTotalRevenue:
          (data['previousTotalRevenue'] ?? 0).toDouble(),
      totalHospitals: data['totalHospitals'] ?? 0,
      totalOrders: data['totalOrders'] ?? 0,
      totalProductsSold: data['totalProductsSold'] ?? 0,
      totalRevenue: (data['totalRevenue'] ?? 0).toDouble(),
    );
  }
}
