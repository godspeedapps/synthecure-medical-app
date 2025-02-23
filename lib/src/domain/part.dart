import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:synthecure/src/domain/doctor.dart';

@immutable
class Part extends Equatable {
  const Part({
    required this.gtin,
    required this.part,
    required this.description,
    required this.quantity,
    required this.lot,
    required this.price,
    required this.hospitals,
    this.id,
  });
  final String gtin;
  final String part;
  final String description;
  final int quantity;
  final String lot;
  final double price;
  final String? id;
  final List<HospitalInfo> hospitals;

  @override
  List<Object> get props => [
        gtin,
        part,
        description,
        quantity,
        lot,
        price,
        id ?? "",
        hospitals
      ];

  factory Part.fromMap(Map<String, dynamic> data) {
    final gtin = data['gtin'] as String;
    final part = data['part'] as String;
    final description = data['description'] as String;
    final quantity = data['quantity'] as int?;
    final lot = data['lot'] as String;
    final price = data['price'] as double?;

    final hospitals = (data['hospitals'] as List<dynamic>?)
            ?.map((e) => HospitalInfo.fromMap(
                e as Map<String, dynamic>))
            .toList() ??
        [];

    final id = data['id'] as String?;

    return Part(
        gtin: gtin,
        part: part,
        description: description,
        quantity: quantity ?? 1,
        lot: lot,
        price: price ?? 0,
        id: id,
        hospitals: hospitals);
  }

  Map<String, dynamic> toMap() {
    return {
      'gtin': gtin,
      'part': part,
      'description': description,
      'quantity': quantity,
      'lot': lot,
      'price': price,
      'id': id,
      if (hospitals.isNotEmpty)
        'hospitals':
            hospitals.map((h) => h.toMap()).toList(),
    };
  }

  Map<String, dynamic> toGeneralMap({required String id}) {
    return {
      'gtin': gtin,
      'part': part,
      'description': description,
      'lot': "",
      'id': id,
    };
  }

  @override
  bool get stringify => true;
}

extension ProductCopy on Part {
  Part copyWith(
      {String? description,
      double? price,
      String? lot,
      String? part,
      String? gtin,
      int? quantity,
      String? id,
      List<HospitalInfo>? hospitals}) {
    return Part(
      description: description ?? this.description,
      price: price ?? this.price,
      lot: lot ?? this.lot,
      part: part ?? this.part,
      gtin: gtin ?? this.gtin,
      quantity: quantity ?? this.quantity,
      id: id ?? this.id,
      hospitals: hospitals ?? this.hospitals,
    );
  }
}
