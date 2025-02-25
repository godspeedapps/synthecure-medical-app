import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:synthecure/src/domain/app_user.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/part.dart';

typedef HospitalID = String;

@immutable
class Hospital extends Equatable {
  const Hospital(
      {required this.id,
      required this.name,
      this.products,
      this.doctors,
      this.email, this.users});
  final HospitalID id;
  final String name;
  final String? email;
  final List<Part>? products;
  final List<Doctor>? doctors;
  final List<SimpleUserInfo>? users;

  @override
  List<Object> get props => [
        name,
        email ?? "null",
        products ?? [],
        doctors ?? [],
        users ?? []
      ];

  @override
  bool get stringify => true;

  factory Hospital.fromMap(
      Map<String, dynamic> data, String id) {
    final name = data['name'] as String;
    final email = data['email'] as String?;
    final products = (data['products'] as List?)
        ?.map((product) => Part.fromMap(product))
        .toList();

    final doctors = (data['doctors'] as List?)
        ?.map((doctor) => Doctor.fromMap(doctor))
        .toList();

    return Hospital(
        id: id,
        name: name,
        email: email,
        products: products ?? [],
        doctors: doctors ?? [],
        users: (data['users'] as List<dynamic>?)
              ?.map((e) => SimpleUserInfo.fromMap(
                  e as Map<String, dynamic>))
              .toList() ??
          [],);
  }

  Map<String, dynamic> toMap(
      {bool includeProducts = true,
      bool includeDoctors = true}) {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (includeProducts)
        'products':
            products?.map((e) => e.toMap()).toList(),
      if (includeDoctors)
        'doctors': doctors?.map((e) => e.toMap()).toList(),
    };
  }

  // Copy with method
  Hospital copyWith({
    String? id,
    String? name,
    String? email,
    List<Part>? products,
    List<Doctor>? doctors,
    List<SimpleUserInfo>? users, 
    bool excludeDoctorHospitals = false,
  }) {
    return Hospital(
      id: this.id, // The ID should remain unchanged
      name: name ?? this.name,
      email: email ?? this.email,
      products: products ?? this.products,
      doctors: doctors ?? this.doctors,
      users: users ?? this.users
    );
  }
}
