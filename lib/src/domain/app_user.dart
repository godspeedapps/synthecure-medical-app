import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:synthecure/src/domain/doctor.dart';

/// Type defining a user ID from Firebase.
typedef UserID = String;

/// Simple class representing the user UID, email, name, and admin status.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isAdmin,
    required this.hospitals,
    this.emailVerified = false,
  });

  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final bool isAdmin;
  final bool emailVerified;
  final List <HospitalInfo> hospitals;

  Future<void> sendEmailVerification() async {
    // no-op - implemented by subclasses
  }

  Future<bool> getIsAdmin() async {
    return Future.value(false);
  }

  Future<void> forceRefreshIdToken() async {
    // no-op - implemented by subclasses
  }

  // * Here we override methods from [Object] directly rather than using
  // * [Equatable], since this class will be subclassed or implemented
  // * by other classes.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUser &&
        other.uid == uid &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.isAdmin == isAdmin;
  }

  @override
  int get hashCode =>
      uid.hashCode ^
      email.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      isAdmin.hashCode;

  @override
  String toString() =>
      'AppUser(uid: $uid, email: $email, firstName: $firstName, lastName: $lastName, isAdmin: $isAdmin, emailVerified: $emailVerified, hospitals: $hospitals)';

  // Factory to create an AppUser from a map (e.g., from Firebase)
  factory AppUser.fromMap(
      Map<String, dynamic> map, String id) {
    return AppUser(
      uid: id,
      email: map['email'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      isAdmin: map['isAdmin'] as bool? ??
          false, // Default to false if not present
      hospitals: (map['hospitals'] as List<dynamic>?)
              ?.map((e) => HospitalInfo.fromMap(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Convert AppUser to a map (e.g., for saving to Firebase)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'isAdmin': isAdmin,
      if (hospitals.isNotEmpty)
        'hospitals':
            hospitals.map((h) => h.toMap()).toList(),
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    bool? isAdmin,
    bool? emailVerified,
    List<HospitalInfo>? hospitals,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isAdmin: isAdmin ?? this.isAdmin,
      emailVerified: emailVerified ?? this.emailVerified,
      hospitals: hospitals ?? this.hospitals,
    );
  }
}


@immutable
class SimpleUserInfo extends Equatable {
  const SimpleUserInfo({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object> get props => [id, name];

  @override
  bool get stringify => true;

  factory SimpleUserInfo.fromMap(Map<String, dynamic> data) {
    return SimpleUserInfo(
      id: data['id'] as String,
      name: data['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // copyWith method
  SimpleUserInfo copyWith({
    String? id,
    String? name,
  }) {
    return SimpleUserInfo(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

