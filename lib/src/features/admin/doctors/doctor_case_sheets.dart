import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/services/entries_service.dart';
import 'package:synthecure/src/domain/order.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/widgets/entry_tile.dart';
import 'package:synthecure/src/widgets/list_items_builder.dart';

class DoctorCaseSheets extends ConsumerWidget {
  final Doctor model;
  const DoctorCaseSheets({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: Text("${model.name}'s Case Sheets",
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

          final entriesTileModelStream = ref.watch(
              adminDoctorEntriesStreamProvider(
                  id: model.id));

          return ListItemsBuilder<Order>(
            data: entriesTileModelStream,
            message: '${model.name} has no case sheets!',
            title: 'No Case Sheets',
            itemBuilder: (context, model) =>
                EntriesListTile(model: model),
          );
        },
      ),
    );
  }
}
