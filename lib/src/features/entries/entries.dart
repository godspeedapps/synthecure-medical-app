import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/repositories/onboarding_repository.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';
import 'package:synthecure/src/services/entries_service.dart';

import 'package:synthecure/src/features/onboarding/presentation/introduction.dart';
import 'package:synthecure/src/domain/order.dart';
import 'package:synthecure/src/features/orders/add_order.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/widgets/entry_tile.dart';

import '../../widgets/list_items_builder.dart';

class EntriesScreen extends ConsumerWidget {
  const EntriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingRepository =
        ref.watch(onboardingRepositoryProvider);

    final didCompleteOnboarding =
        onboardingRepository.isOnboardingComplete();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!didCompleteOnboarding) {
        showCupertinoModalSheet(
          context: context,
          builder: (context) {
            return Onboarding(
            );
          },
        );
      }
    });

    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: Text("All Case Sheets",
            style: Theme.of(context).textTheme.titleMedium),
        trailing: IconButton(
            onPressed: () {
              context.pushNamed(AppRoute.createOrder.name);

              //  Navigator.of(context).push(

              //     CupertinoSheetRoute<void>(

              //       builder: (BuildContext context) => const AddPage(),
              //     ),
              //   );
            },
            icon: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Icon(
                CupertinoIcons.plus_square_on_square,
                size: 30,
                color:
                    Theme.of(context).colorScheme.primary,
              ),
            )),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          // * This data is combined from two streams, so it can't be returned
          // * directly as a Query object from the repository.
          // * As a result, we can't use FirestoreListView here.

          // return Container(); }

          final entriesTileModelStream =
              ref.watch(entriesTileModelStreamProvider(id:ref.read(firebaseAuthProvider).currentUser!.uid));

          return ListItemsBuilder<Order>(
            data: entriesTileModelStream,
            title: "No case sheets",
            message: "Add to get started ⤴️",
            itemBuilder: (context, model) =>
                EntriesListTile(model: model),
          );
        },
      ),
    );
  }
}
