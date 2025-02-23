import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef DoctorID = String;

@immutable
class HospitalInfo extends Equatable {
  const HospitalInfo(
      {required this.id, required this.name,  this.price = 0.0, });

  final String id;
  final String name;
  final double price;
  

  @override
   List<Object> get props => [id, name, price];

  @override
  bool get stringify => true;

  factory HospitalInfo.fromMap(Map<String, dynamic> data) {
    return HospitalInfo(
      id: data['id'] as String,
      name: data['name'] as String,
      price: (data['price'] as num?)?.toDouble() ?? 0.0, 
    );
  }

 Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      if(price != 0.0)
      'price': price, // Include price in map
    };
  }

   // copyWith method
  HospitalInfo copyWith({
    String? id,
    String? name,
    double? price,
  }) {
    return HospitalInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }
}

@immutable
class Doctor extends Equatable {
  const Doctor(
      {required this.id,
      required this.name,
      required this.hospitals});

  final DoctorID id;
  final String name;
  final List<HospitalInfo> hospitals;

  @override
  List<Object> get props => [id, name, hospitals];

  @override
  bool get stringify => true;

  factory Doctor.fromMap(Map<String, dynamic> data) {
    return Doctor(
      id: data['id'] as String,
      name: data['name'] as String,
      hospitals: (data['hospitals'] as List<dynamic>?)
              ?.map((e) => HospitalInfo.fromMap(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      if (hospitals.isNotEmpty)
        'hospitals':
            hospitals.map((h) => h.toMap()).toList(),
    };
  }

  Doctor copyWith({
    DoctorID? id,
    String? name,
    List<HospitalInfo>? hospitals,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      hospitals: hospitals ?? this.hospitals,
    );
  }
}
