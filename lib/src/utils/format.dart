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
}
