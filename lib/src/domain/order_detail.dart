class OrderDetail {
  final String hospitalId;
  final double orderTotal;
  final String orderId;
  final String doctorId;
  final bool status; // ✅ Added status (isClosed)

  OrderDetail({
    required this.hospitalId,
    required this.orderTotal,
    required this.orderId,
    required this.doctorId,
    required this.status, // ✅ Added status
  });

  factory OrderDetail.fromMap(Map<String, dynamic> data) {
    return OrderDetail(
      hospitalId: data["hospitalId"] ?? "",
      orderTotal: _parseDouble(data["orderTotal"]),
      orderId: data["orderId"] ?? "",
      doctorId: data["doctorId"] ?? "",
      status: _parseBool(data["status"]), // ✅ Added status parsing
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is int) {
      return value == 1;
    } else if (value is String) {
      return value.toLowerCase() == "true";
    }
    return false; // Default to false if the value is missing or invalid
  }
}
