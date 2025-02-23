import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:signature/signature.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/features/entries/entries.dart';
import 'package:synthecure/src/domain/order.dart';
import 'package:synthecure/src/features/orders/edit_order_screen/edit_order_screen_controller.dart';
import 'package:synthecure/src/features/orders/orders_screen_controller.dart';
import 'package:synthecure/src/utils/alert_dialogs.dart';
import 'package:synthecure/src/utils/case_screenshot.dart';
import 'package:synthecure/src/utils/snackbars.dart';

import '../../domain/part.dart';

class EntryView extends ConsumerStatefulWidget {
  final Order model;

  const EntryView({super.key, required this.model});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EntryViewState();
}

class _EntryViewState extends ConsumerState<EntryView> {
  double totalPrice = 0;
  double tnTax = .0975;

  @override
  void initState() {
    totalPrice = calculateTotal(widget.model);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;

    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: Text(
          '${DateFormat.yMd().format(model.date)} at ${DateFormat.jm().format(model.date)}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        trailing: model.isClosed
            ? null
            : GestureDetector(
                onTap: () => showSignatureBox(
                    context, ref, model, totalPrice, tnTax),
                child: const Icon(
                  CupertinoIcons.paperplane,
                  color: CupertinoColors.black,
                  size: 25,
                )),
      ),
      body: CupertinoScrollbar(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Opacity(
                    opacity: 0.4,
                    child: Image.asset(
                      "assets/Synthecure_Logo.jpg",
                      scale: 2.2,
                    )),
              ),
            ),
            Material(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  gapH12,
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0),
                    child: Opacity(
                        opacity: 0.4,
                        child: Text(
                          '#${model.id}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium,
                        )),
                  ),
                  gapH8,
                  Opacity(
                    opacity: 0.8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          gapW12,
                          Text(
                            '${DateFormat.yMd().format(model.date)} at ${DateFormat.jm().format(model.date)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  gapH12,
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0),
                      child: Divider(
                        height: 1.0,
                        thickness: 0.4,
                        color:
                            Theme.of(context).dividerColor,
                      )),
                  CupertinoListSection.insetGrouped(
                    margin: const EdgeInsets.all(8.0),
                    backgroundColor: Colors.white,
                    header: Text(
                      'CASE SHEET',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall,
                    ),
                    children: [
                      CupertinoListTile(
                        leading: const Icon(
                          Icons.local_hospital,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                        title: Text(
                          model.hospital.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall,
                        ),
                        subtitle: Opacity(
                            opacity: 0.6,
                            child: Text(
                              'Hospital Name',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            )),
                        // trailing:
                        //     const CupertinoListTileChevron(),
                        onTap: () {},
                      ),
                      CupertinoListTile(
                        leading: Icon(
                          CupertinoIcons.person_circle,
                          size: 25,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                        title: Text(
                          "Dr. ${model.doctor.name}",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall,
                        ),
                        subtitle: Opacity(
                            opacity: 0.6,
                            child: Text(
                              'Doctor Name',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            )),
                        // trailing:
                        //     const CupertinoListTileChevron(),
                        onTap: () {},
                      ),
                      CupertinoListTile(
                        leading: const Icon(
                          CupertinoIcons.doc,
                          size: 20,
                        ),
                        title: Text(
                          model.patient,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall,
                        ),
                        subtitle: Opacity(
                            opacity: 0.6,
                            child: Text(
                              'Case ID',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            )),
                        // trailing:
                        //     const CupertinoListTileChevron(),
                        onTap: () {},
                      ),
                      CupertinoListTile(
                        leading: const Icon(
                          CupertinoIcons.mail,
                          size: 20,
                        ),
                        title: Text(
                          model.hospital.email ??
                              "hospital@gmail.com",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall,
                        ),
                        subtitle: Opacity(
                            opacity: 0.6,
                            child: Text(
                              'Email Address',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            )),
                        // trailing:
                        //     const CupertinoListTileChevron(),
                        onTap: () async {
                          final choice = await showAlertDialog(
                              context: context,
                              content:
                                  "You will be prompted to resubmit email.",
                              title:
                                  "Re-deliver case sheet?",
                              defaultActionText: "Yes",
                              cancelActionText: "Cancel");

                          if (choice == true &&
                              context.mounted) {
                            await showSignatureBox(
                                context,
                                ref,
                                model,
                                totalPrice,
                                tnTax);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            gapH12,
            Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  gapH16,
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0),
                    child: Text(
                      "Your Summary",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall,
                    ),
                  ),
                  ExpansionTileGroup(
                    toggleType: ToggleType
                        .expandOnlyCurrent, // Only one can expand at a time
                    spaceBetweenItem:
                        0, // No spacing between tiles
                    children: model.part.map((part) {
                      // Iterating over all
                      return ExpansionTileItem(
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment:
                              MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.all(4.0),
                              child: Text(
                                "\$${part.price}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                                CupertinoIcons.chevron_down,
                                size: 18),
                          ],
                        ),
                        childrenPadding: EdgeInsets.zero,
                        expendedBorderColor:
                            Colors.transparent,
                        title: Row(
                          children: [
                            Flexible(
                                child:
                                    Text(part.description)),
                            Text(
                              "  x${part.quantity}",
                              style: const TextStyle(
                                  fontSize: 12),
                            )
                          ],
                        ),
                        leading: const Icon(
                            CupertinoIcons.lab_flask),
                        children: [
                          ListTile(
                            title: Text(part.lot),
                            subtitle:
                                const Text("LOT NUMBER"),
                          ),
                          ListTile(
                            title: Text(part.part),
                            subtitle:
                                const Text("PART NUMBER"),
                          ),
                          ListTile(
                            title: Text(part.gtin),
                            subtitle: const Text("GTIN"),
                          ),
                        ],
                      );
                    }).toList(), // Convert map result back to a list
                  ),
                  // ExpansionTileGroup(
                  //     toggleType: ToggleType
                  //         .expandOnlyCurrent, // Only one can expand at a time
                  //     spaceBetweenItem:
                  //         0, // Spacing between tiles
                  //     children: [
                  //       // Paycheck Tile 1
                  //       ExpansionTileItem(
                  //         trailing: Row(
                  //           mainAxisSize: MainAxisSize.min,
                  //           children: [
                  //             Text(
                  //               "\$${(totalPrice * tnTax).toStringAsFixed(2)}",
                  //               style: Theme.of(context)
                  //                   .textTheme
                  //                   .titleSmall,
                  //             ),
                  //             gapW12,
                  //             const Icon(
                  //               CupertinoIcons.chevron_down,
                  //               size: 18,
                  //             ),
                  //           ],
                  //         ),
                  //         childrenPadding: EdgeInsets.zero,
                  //         expendedBorderColor:
                  //             Colors.transparent,
                  //         title: const Text("Taxes"),
                  //         leading: const Icon(
                  //             CupertinoIcons.list_dash),
                  //         children: [
                  //           ListTile(
                  //             title: Text(
                  //                 "9.75% X $totalPrice"),
                  //             subtitle: const Text(
                  //                 "TENNESSEE SALES TAX"),
                  //           ),
                  //         ],
                  //       ),
                  //     ]),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0),
                    child: ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15)),
                        tileColor: Colors.white,
                        leading: const Icon(CupertinoIcons
                            .money_dollar_circle),
                        title: Text(
                          "Total Balance",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall,
                        ),
                        trailing: Text(
                          "\$${(totalPrice).toStringAsFixed(2)}",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall,
                        )),
                  ),
                ],
              ),
            ),
     
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(
                      16.0), // Add padding inside the container
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Notes",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall,
                      ),
                      const SizedBox(
                          height:
                              8.0), // Add spacing between title and notes
                    Text(
                        model.notes.isNotEmpty
                            ? model.isRestock
                                ? "${model.notes}\nThis is a restock order."
                                : model.notes
                            : model.isRestock
                                ? "This is a restock order."
                                : "No additional information provided.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                     
                    ],
                  ),
                ),
              ),
            CupertinoListSection.insetGrouped(
              backgroundColor:
                  Theme.of(context).scaffoldBackgroundColor,
              topMargin: 0,
              children: [
                CupertinoListTile(
                  leading: const Icon(
                      CupertinoIcons.delete_simple,
                      size: 22,
                      color: CupertinoColors.systemRed),
                  title: Text('Delete Case Sheet',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                              color: CupertinoColors
                                  .systemRed)),
                  trailing:
                      const CupertinoListTileChevron(),
                  onTap: () {
                    showCupertinoDialog(
                        context: context,
                        builder: (context) =>
                            CupertinoAlertDialog(
                              title: const Text(
                                  'Delete Case Sheet'),
                              content: const Text(
                                  'Are you sure you want to delete this case sheet?'),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () =>
                                      Navigator.pop(
                                          context),
                                  child:
                                      const Text('Cancel'),
                                ),
                                Consumer(
                                  builder: (context, ref,
                                      child) {
                                    final state = ref.watch(
                                        orderScreenControllerProvider);

                                    return CupertinoDialogAction(
                                      isDestructiveAction:
                                          true,
                                      onPressed: state
                                              .isLoading
                                          ? null // Disable button during loading
                                          : () async {
                                              final success = await ref
                                                  .read(orderScreenControllerProvider
                                                      .notifier)
                                                  .deleteOrder(
                                                      widget
                                                          .model);

                                              if (success &&
                                                  context
                                                      .mounted) {
                                                context
                                                    .pop(); // Close the dialog

                                                showSuccessSnackbar(
                                                    context,
                                                    "Case sheet has been deleted!");

                                                context
                                                    .pop();
                                              } else if (context
                                                  .mounted) {
                                                showErrorSnackbar(
                                                    context,
                                                    "Failed to delete order, Try again.");
                                              }
                                            },
                                      child: state.isLoading
                                          ? const CupertinoActivityIndicator() // Show loader
                                          : const Text(
                                              'Delete'), // Default text
                                    );
                                  },
                                ),
                              ],
                            ));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Riverpod StateProvider for SignatureController
final signatureControllerProvider =
    StateProvider<SignatureController>((ref) {
  return SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
    exportPenColor: Colors.black,
    onDrawStart: () => print('onDrawStart called!'),
    onDrawEnd: () => print('onDrawEnd called!'),
  );
});

class SignatureBox extends ConsumerWidget {
  const SignatureBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signatureController =
        ref.watch(signatureControllerProvider);

    return SizedBox(
      height: 200,
      child: Material(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)),
        child: Signature(
          // key: const Key('signature'),
          controller: signatureController,
          height: 150,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

double calculateTotal(Order model) {
  double totalPrice = 0; // Reset before calculation
  for (var e in model.part) {
    if (e.price != 0) {
      totalPrice +=
          e.price * e.quantity; // Parse and calculate
    }
  }
  return totalPrice;
}
