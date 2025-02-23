import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/domain/part.dart';

typedef OrderID = String;
@immutable
class Order extends Equatable {
  const Order({
    required this.id,
    required this.date,
    required this.doctor,
    required this.hospital,
    required this.part,
    required this.patient,
    required this.isClosed,
    required this.notes,
    required this.createdBy,
    required this.isRestock, // ✅ New field
  });

  final OrderID id;
  final DateTime date;
  final Doctor doctor;
  final Hospital hospital;
  final List<Part> part;
  final String patient;
  final bool isClosed;
  final String notes;
  final String createdBy;
  final bool isRestock; // ✅ New field

  @override
  List<Object> get props => [
        date,
        doctor,
        hospital,
        part,
        patient,
        isClosed,
        notes,
        createdBy,
        isRestock, // ✅ Include in props
      ];

  @override
  bool get stringify => true;

  factory Order.fromMap(Map<String, dynamic> data, String id) {
    final date = DateTime.parse(data['date'].toDate().toString());
    final doctor = Doctor.fromMap(data['doctor']);
    final hospital = Hospital.fromMap(data['hospital'], id);
    final part = (data['products'] as List).map((product) => Part.fromMap(product)).toList();
    final patient = data['patient'] as String;
    final isClosed = data['isClosed'] as bool;
    final notes = data['notes'] ?? "";
    final createdBy = data['createdBy'] as String;
    final isRestock = data['isRestock'] ?? false; // ✅ Default to false if missing

    return Order(
      id: id,
      date: date,
      doctor: doctor,
      hospital: hospital,
      part: part,
      patient: patient,
      isClosed: isClosed,
      notes: notes,
      createdBy: createdBy,
      isRestock: isRestock, // ✅ Add field
    );
  }

  factory Order.fromFormMap(
    Map<String, dynamic> data,
    String id,
    bool isClosedVal,
    List<Part> products,
  ) {
    final date = data['date'];
    final doctor = data['doctor'];
    final hospital = data['hospital'];
    final part = products;
    final patient = data['patient'];
    final isClosed = isClosedVal;
    final notes = data['notes'];
    final createdBy = data['createdBy'];
    final isRestock = data['isRestock'] ?? false; // ✅ Default to false

    return Order(
      id: id,
      date: date,
      doctor: doctor,
      hospital: hospital,
      part: part,
      patient: patient,
      isClosed: isClosed,
      notes: notes,
      createdBy: createdBy,
      isRestock: isRestock, // ✅ Add field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'doctor': doctor.toMap(),
      'hospital': hospital.toMap(),
      'products': part.map((e) => e.toMap()).toList(),
      'patient': patient,
      'isClosed': isClosed,
      'notes': notes,
      'createdBy': createdBy,
      'isRestock': isRestock, // ✅ Include in map
    };
  }

  /// CopyWith method to create a modified copy of the `Order`.
  Order copyWith({
    OrderID? id,
    DateTime? date,
    Doctor? doctor,
    Hospital? hospital,
    List<Part>? part,
    String? patient,
    bool? isClosed,
    String? notes,
    String? createdBy,
    bool? isRestock, // ✅ Add to copyWith
  }) {
    return Order(
      id: id ?? this.id,
      date: date ?? this.date,
      doctor: doctor ?? this.doctor,
      hospital: hospital ?? this.hospital,
      part: part ?? this.part,
      patient: patient ?? this.patient,
      isClosed: isClosed ?? this.isClosed,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      isRestock: isRestock ?? this.isRestock, // ✅ Add field
    );
  }
}

