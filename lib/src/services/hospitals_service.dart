
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synthecure/src/domain/hospital.dart';
import '../repositories/firebase_auth_repository.dart';
import '../domain/app_user.dart';
import '../repositories/orders_repository.dart';
part 'hospitals_service.g.dart';

class HospitalsService {
  HospitalsService(
      {required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Stream<List<Hospital>> _allHospitalsStream(UserID uid) =>
      ordersRepository.watchHospitals(uid: uid).map(_sortHospitals);


  Stream<List<Hospital>> hospitalsTileModelStream(UserID uid) =>
      _allHospitalsStream(uid);


 /// Sort users alphabetically by name
 static List<Hospital> _sortHospitals(List<Hospital> hospitals) {
  // First, sort by whether the user is an admin (admin at the top)
  hospitals.sort((a, b) {

    return a.name.compareTo(b.name); // Alphabetical order by last name
  });
  return hospitals;
}

}

@riverpod
HospitalsService hospitalsService(HospitalsServiceRef ref) {
  return HospitalsService(
    ordersRepository: ref.watch(ordersRepositoryProvider),
  );
}

@riverpod
Stream<List<Hospital>> hospitalsTileModelStream(HospitalsTileModelStreamRef ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw AssertionError('User can\'t be null when fetching entries');
  }
  final hospitalsService = ref.watch(hospitalsServiceProvider);

  return hospitalsService.hospitalsTileModelStream(user.uid);
}

