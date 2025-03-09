import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:synthecure/src/domain/app_user.dart';
import 'package:synthecure/src/domain/doctor.dart';

class Format {
  static String hours(double hours) {
    final hoursNotNegative = hours < 0.0 ? 0.0 : hours;
    final formatter = NumberFormat.decimalPattern();
    final formatted = formatter.format(hoursNotNegative);
    return '${formatted}h';
  }

  static String date(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  static String dayOfWeek(DateTime date) {
    return DateFormat.E().format(date);
  }

  static String currency(double pay) {
    if (pay != 0.0) {
      final formatter =
          NumberFormat.simpleCurrency(decimalDigits: 0);
      return formatter.format(pay);
    }
    return '';
  }  
  
  
  static String formatSalesCurrency(double value) {
  final formatter = NumberFormat('#,##0.##', 'en_US');
  return formatter.format(value);
  }

static String formatRoundedNumber(double value) {
  if (value <= 0) return "\$0"; // ✅ Edge case: No negative or zero values

  int roundedValue = ((value ~/ 500) * 500); // ✅ Always round down to nearest 500

  return "\$${roundedValue.toStringAsFixed(0)}"; // ✅ Ensure proper formatting
}

static double calculatePercentChange(double current, double previous) {
  if (previous == 0) return 100.0;
  final change = ((current - previous) / previous) * 100;
  return change;
}

  static String getHospitalDisplayText(
      List<HospitalInfo> hospitals) {
    if (hospitals.isEmpty) return "No hospitals";

    hospitals
        .shuffle(); // Shuffle to pick a random hospital
    final randomHospital = hospitals.first;
    final othersCount = hospitals.length - 1;

    return othersCount > 0
        ? "${randomHospital.name} (and $othersCount other${othersCount > 1 ? 's' : ''})"
        : randomHospital.name;
  }

  static String getHospitalUsersText(
      List<SimpleUserInfo> users) {
    String userText = "No Reps";

    if (users.isNotEmpty) {
      final randomUser = (users..shuffle()).first;
      final othersCount = users.length - 1;
      userText = othersCount > 0
          ? "${randomUser.name} and $othersCount others"
          : randomUser.name;
    }

    return userText;
  }

  static String getTimePeriodText(String mode) {
      switch (mode) {
        case "daily":
          return "Today";
        case "weekly":
          return "This Week";
        case "monthly":
          return "This Month";
        case "yearly":
          return "This Year";
        default:
          return "All Time";
      }
    }
    

}
