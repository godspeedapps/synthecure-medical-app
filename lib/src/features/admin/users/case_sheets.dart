import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/domain/app_user.dart';
import 'package:synthecure/src/services/entries_service.dart';
import 'package:synthecure/src/domain/order.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/widgets/entry_tile.dart';
import 'package:synthecure/src/widgets/list_items_builder.dart';

class UserCaseSheets extends ConsumerWidget {
  final AppUser model;
  const UserCaseSheets({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: Text("${model.firstName}'s Case Sheets",
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
              entriesTileModelStreamProvider(
                  id: model.uid));

          return ListItemsBuilder<Order>(
            data: entriesTileModelStream,
            title: "No Case Sheets",
            message: "This user does not have any active sheets 😔",
            itemBuilder: (context, model) =>
                EntriesListTile(model: model),
          );
        },
      ),
    );
  }
}
