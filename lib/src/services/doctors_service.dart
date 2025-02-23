import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';
import 'package:synthecure/src/domain/app_user.dart';
import 'package:synthecure/src/repositories/orders_repository.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/repositories/doctor_repository.dart';

part 'doctors_service.g.dart';


class DoctorsService {
  DoctorsService(
      {required this.doctorRepository});

  final DoctorRepository doctorRepository;

  Stream<List<Doctor>> _allDoctorsStream(UserID uid) =>
      doctorRepository.watchAllDoctors().map(_sortDoctors);


  Stream<List<Doctor>> doctorsTileModelStream(UserID uid) =>
      _allDoctorsStream(uid);

  
  /// Sort users alphabetically by name
 static List<Doctor> _sortDoctors(List<Doctor> doctors) {
  // First, sort by whether the user is an admin (admin at the top)
  doctors.sort((a, b) {

    return a.name.compareTo(b.name); // Alphabetical order by last name
  });
  return doctors;
}

}

@riverpod
DoctorsService doctorsService(DoctorsServiceRef ref) {
  return DoctorsService(
    doctorRepository: ref.watch(doctorRepositoryProvider),
  );
}

@riverpod
Stream<List<Doctor>> doctorsTileModelStream(DoctorsTileModelStreamRef ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw AssertionError('User can\'t be null when fetching entries');
  }
  final hospitalsService = ref.watch(doctorsServiceProvider);

  return hospitalsService.doctorsTileModelStream(user.uid);
}

