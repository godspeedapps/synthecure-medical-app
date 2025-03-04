import 'package:synthecure/src/repositories/entries_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/firebase_auth_repository.dart';
import '../domain/app_user.dart';
import '../repositories/orders_repository.dart';
import '../domain/order.dart';

part 'entries_service.g.dart';

class EntriesService {
  EntriesService(
      {required this.ordersRepository, required this.entriesRepository});

  final OrdersRepository ordersRepository;
  final EntriesRepository entriesRepository;

  Stream<List<Order>> _allEntriesStream(UserID uid) =>
      entriesRepository.watchEntries(uid: uid);

  Stream<List<Order>> _pastEntriesStream(UserID uid) =>
      entriesRepository.watchPastEntries(uid: uid);

  Stream<List<Order>> entriesTileModelStream(UserID uid) =>
      _allEntriesStream(uid).map(sortFunction);

  Stream<List<Order>> pastEntriesModelStream(UserID uid) =>
      _pastEntriesStream(uid).map(sortFunction);

 static List<Order> sortFunction(List<Order> allEntries) {
  if (allEntries.isEmpty) {
    return [];
  }

  allEntries.sort((a, b) {
    // Prioritize isClosed == false orders first
    if (a.isClosed == b.isClosed) {
      return b.date.compareTo(a.date); // Sort by date descending
    }
    return a.isClosed ? 1 : -1; // Place open orders first
  });

  return allEntries;
}
   // *** ADMIN ALL ORDER STREAM
  Stream<List<Order>> adminEntriesStream() =>
      entriesRepository.watchAllOrders().map(sortFunction);

    // *** ADMIN HOSPITAL ORDER STREAM
  Stream<List<Order>> adminHospitalEntriesStream({required String id}) =>
      entriesRepository.watchHospitalOrders(hospitalId: id).map(sortFunction);


    // *** ADMIN DOCTOR ORDER STREAM
   Stream<List<Order>> adminDoctorEntriesStream({required String id}) =>
      entriesRepository.watchDoctorsOrders(doctorId: id).map(sortFunction);

}

@riverpod
// ignore: deprecated_member_use_from_same_package
EntriesService entriesService(EntriesServiceRef ref) {
  return EntriesService(
    ordersRepository: ref.watch(ordersRepositoryProvider),
    entriesRepository: ref.watch(entriesRepositoryProvider),
  );
}

@riverpod
Stream<List<Order>> entriesTileModelStream(EntriesTileModelStreamRef ref, {
  required String id, // Accept an id argument
}) {
  final user = ref.watch(firebaseAuthProvider).currentUser;

  if (user == null) {
    throw AssertionError('User can\'t be null when fetching entries');
  }

  final entriesService = ref.watch(entriesServiceProvider);

  return entriesService.entriesTileModelStream(id);
}


@Riverpod(keepAlive: true)
Stream<List<Order>> adminEntriesStream(AdminEntriesStreamRef ref) {
  final entriesService = ref.watch(entriesServiceProvider);

  return entriesService.adminEntriesStream();
}

@riverpod
Stream<List<Order>> adminHospitalEntriesStream(AdminEntriesStreamRef ref, {
  required String id, // Accept an id argument
}) {
  final entriesService = ref.watch(entriesServiceProvider);

  return entriesService.adminHospitalEntriesStream(id: id);
}


@riverpod
Stream<List<Order>> adminDoctorEntriesStream(AdminEntriesStreamRef ref, {
  required String id, // Accept an id argument
}) {
  final entriesService = ref.watch(entriesServiceProvider);

  return entriesService.adminDoctorEntriesStream(id: id);
}

