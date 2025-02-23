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
import 'package:synthecure/src/domain/order.dart';
import 'package:synthecure/src/domain/part.dart';
import 'package:synthecure/src/features/entries/entry_view.dart';
import 'package:synthecure/src/features/orders/edit_order_screen/edit_order_screen_controller.dart';
import 'package:synthecure/src/utils/snackbars.dart';




 Future<void> showSignatureBox(
      BuildContext context, WidgetRef ref, Order model, double totalPrice, double tnTax) {
    
    
      return showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Add Nurse Signature:'),
        ),
        message: const SignatureBox(),
        actions: [
          CupertinoActionSheetAction(
              onPressed: () {
                ref
                    .read(signatureControllerProvider
                        .notifier)
                    .state = SignatureController(
                  penStrokeWidth: 1,
                  penColor: Colors.black,
                  exportBackgroundColor: Colors.white,
                );
              },
              child: const Text(
                "Clear Signature",
                style: TextStyle(
                    color: CupertinoColors.systemRed,
                    fontSize: 14),
              ))
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () async {
            final signatureController =
                ref.read(signatureControllerProvider);

            if (signatureController.isEmpty) {
              // Show an alert if the signature is empty
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Signature Required'),
                  content: const Text(
                      'You must provide your signature before delivering a case sheet'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () =>
                          Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else {
              // Signature is valid, perform your action
              // Navigator.pop(context);

         
               final signature = await signatureController.toPngBytes();
                 

              if (context.mounted) {
                showCaseScreenshot(context, model, null,
                    totalPrice, tnTax, signature);
              }
            }
          },
          child: const Text(
            'Deliver Case Sheet',
          ),
        ),
      ),
    );
  }

Future<dynamic> showCaseScreenshot(
    BuildContext context,
    Order model,
    User? user,
    double totalPrice,
    double tnTax, Uint8List? signature) {
  final ScreenshotController screenshotController =
      ScreenshotController();

  Future<File> createTemporaryImageFile(
      Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempImagePath = '${tempDir.path}/temp_image.png';

    final tempImageFile = File(tempImagePath);
    await tempImageFile.writeAsBytes(imageBytes);

    return tempImageFile;
  }

  Future<void> launchEmail({
    required String toEmail,
    required String cc,
    required String subject,
    required Order order,
    required File image,
  }) async {
    final Email email = Email(
      subject: subject,
      recipients: [toEmail],
      cc: [cc],
      bcc: [model.hospital.email!],
      attachmentPaths: [image.path],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);

    // final url = Uri.parse(
    //     'mailto:$toEmail?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull("Order ID : ${order.id}\n Date : ${order.date}\n Hospital: ${order.hospital.name}\n Doctor : ${order.doctor}\n Patient ID : ${order.patient}\n\n Products: ${order.part}\n Notes : ${order.notes}")}');

    // if (await canLaunchUrl(url)) {
    //   await launchUrl(url);
    // }
  }

  var myLongWidget = Builder(builder: (context) {
    Widget caseSheetRow({
      required IconData icon,
      required String title,
      required String subtitle,
      Color? iconColor,
    }) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 24, color: iconColor ?? Colors.black),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall),
              SizedBox(height: 4),
              Text(subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall),
            ],
          ),
        ],
      );
    }

    Widget detailsRow(String subtitle, String title) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 4.0), // Add spacing between rows
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.circle,
                size: 6,
                color: Colors
                    .grey), // A small bullet or marker
            const SizedBox(
                width: 8), // Spacing between icon and text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildProductDetails(Part part) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          detailsRow("LOT NUMBER", part.lot),
          detailsRow("PART NUMBER", part.part),
          detailsRow("GTIN", part.gtin),
        ],
      );
    }

    Widget buildSummaryRow(Part part) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  constraints: BoxConstraints(
                      maxWidth:
                          200), // Set a reasonable max width for text
                  child: Text(
                    part.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                    overflow: TextOverflow
                        .ellipsis, // Ensure text truncates if it overflows
                  ),
                ),
           
                  Padding(
                    padding: const EdgeInsets.only(
                        left:
                            8.0), // Add spacing between items
                    child: Text(
                      "x${part.quantity}",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "\$${part.price.toStringAsFixed(2)}", // Ensure consistent formatting
                style:
                    Theme.of(context).textTheme.titleSmall,
              ),
            ),

            const SizedBox(
                height:
                    8), // Space between summary and details
            // Product details
            buildProductDetails(part),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white, // Set the background color
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Section
          Align(
            alignment: Alignment.centerLeft,
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                "assets/Synthecure_Logo.jpg",
                scale: 2.2,
              ),
            ),
          ),

          // Case Details Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              Opacity(
                opacity: 0.4,
                child: Text(
                  '#${model.id}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),
              ),
              SizedBox(height: 16),
              Opacity(
                opacity: 0.8,
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.calendar_today),
                    SizedBox(width: 12),
                    Text(
                      '${DateFormat.yMd().format(model.date)} at ${DateFormat.jm().format(model.date)}',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Divider(
                height: 1.0,
                thickness: 0.4,
                color: Theme.of(context).dividerColor,
              ),
            ],
          ),
          gapH16,

          // Case Sheet Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CASE SHEET',
                style:
                    Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: 8),
              caseSheetRow(
                icon: Icons.local_hospital,
                title: model.hospital.name,
                subtitle: 'Hospital Name',
                iconColor: Colors.redAccent,
              ),
              SizedBox(height: 8),
              caseSheetRow(
                icon: CupertinoIcons.person_circle,
                title: "Dr. ${model.doctor.name}",
                subtitle: 'Doctor Name',
                iconColor:
                    Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 8),
              caseSheetRow(
                icon: CupertinoIcons.doc,
                title: model.patient,
                subtitle: 'Case ID',
              ),
            ],
          ),
          gapH16,

          // Summary Section
          Text(
            "Your Summary",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          gapH8,

          Divider(
            height: 1.0,
            thickness: 0.4,
            color: Theme.of(context).dividerColor,
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: model.part.map((part) {
                return buildSummaryRow(part);
              }).toList(),
            ),
          ),

          // Taxes Section
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         mainAxisAlignment:
          //             MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text(
          //             "Taxes",
          //             style: Theme.of(context)
          //                 .textTheme
          //                 .titleSmall,
          //           ),
          //           Text(
          //             "\$${(totalPrice * tnTax).toStringAsFixed(2)}",
          //             style: Theme.of(context)
          //                 .textTheme
          //                 .titleSmall,
          //           ),
          //         ],
          //       ),
          //       SizedBox(height: 8),
          //       Text(
          //         "9.75% X ${totalPrice.toStringAsFixed(2)}",
          //         style: Theme.of(context)
          //             .textTheme
          //             .bodyMedium,
          //       ),
          //     ],
          //   ),
          // ),

          // Total Balance Due
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 0.4),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Balance",
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall,
                  ),
                  gapW12,
                  Text(
                    "\$${(totalPrice).toStringAsFixed(2)}",
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall,
                  ),
                ],
              ),
            ),
          ),

          // Notes Section

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 0.4),
                ),
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
                    SizedBox(height: 8),
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
            gapH8,
             Divider(
            height: 1.0,
            thickness: 0.4,
            color: Theme.of(context).dividerColor,
          ),
          gapH16,
             // Display the saved signature
           if (signature != null)
                      Container(
                        
                      
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                                "Nurse Signature",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            
                            const SizedBox(height: 16),
                            Center( // Centers the image
                              child: Image.memory(
                                signature,
                                scale: 2,
                                // Ensures it scales properly
                              ),
                            ),
                             const SizedBox(height: 12),
                          ],
                        ),
                      ),
        ],
      ),
    );
  });

  return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) {
        return Scaffold(
          appBar: CupertinoNavigationBar(
            backgroundColor: Colors.white,
            middle: Text(
              'Review Summary',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            trailing:
                Consumer(builder: (context, ref, child) {
              return GestureDetector(
                  onTap: () async {
                    await screenshotController
                        .captureFromLongWidget(
                            pixelRatio:
                                MediaQuery.of(context)
                                    .devicePixelRatio,
                            InheritedTheme.captureAll(
                              context,
                              Material(
                                  child: MediaQuery(
                                      data: MediaQuery.of(
                                          context),
                                      child: myLongWidget)),
                            ),
                            delay: const Duration(
                                milliseconds: 10))
                        .then((capturedImage) async {
                      final image =
                          await createTemporaryImageFile(
                              capturedImage);

                      await launchEmail(
                          toEmail: 'orders@synthecure.com',
                          cc: model.hospital.email ?? "",
                          subject: 'Synthecure Usage',
                          order: model,
                          image: image);
                    });

                    final updatedOrder = await ref
                        .read(
                            editJobScreenControllerProvider
                                .notifier)
                        .updateOrder(order: model);

                    if (updatedOrder != null && context.mounted) {
                      while (context.canPop()) {
                        context.pop();
                      }

                      showSuccessSnackbar(context,
                          "You have delivered case sheet ${model.id}");
                    } else if (context.mounted) {
                      showErrorSnackbar(context,
                          "Couldn't add case sheet, Try again!"); // Show error message
                    }
                  },
                  child: const Icon(
                    CupertinoIcons.checkmark_alt_circle,
                    color: CupertinoColors.systemGreen,
                    size: 35,
                  ));
            }),
          ),
          body: CupertinoScrollbar(
              child: Screenshot(
            controller: screenshotController,
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
                    mainAxisAlignment:
                        MainAxisAlignment.start,
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
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 24.0),
                          child: Row(
                            children: [
                              const Icon(
                                  Icons.calendar_today),
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
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 24.0),
                          child: Divider(
                            height: 1.0,
                            thickness: 0.4,
                            color: Theme.of(context)
                                .dividerColor,
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
                            onTap: () {},
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
                      borderRadius:
                          BorderRadius.circular(10),
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
                            .expandAll, // Only one can expand at a time
                        spaceBetweenItem:
                            0, // No spacing between tiles
                        children: model.part.map((part) {
                          // Iterating over all
                          return ExpansionTileItem(
                            initiallyExpanded: true,
                            trailing: Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Text(
                                  "\$${part.price}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                    CupertinoIcons
                                        .chevron_down,
                                    size: 18),
                              ],
                            ),
                            childrenPadding:
                                EdgeInsets.zero,
                            expendedBorderColor:
                                Colors.transparent,
                            title: Row(
                              children: [
                                Flexible(
                                    child: Text(
                                        part.description)),
                         
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
                                subtitle: const Text(
                                    "LOT NUMBER"),
                              ),
                              ListTile(
                                title: Text(part.part),
                                subtitle: const Text(
                                    "PART NUMBER"),
                              ),
                              ListTile(
                                title: Text(part.gtin),
                                subtitle:
                                    const Text("GTIN"),
                              ),
                            ],
                          );
                        }).toList(), // Convert map result back to a list
                      ),
                      // ExpansionTileGroup(
                      //     toggleType: ToggleType
                      //         .expandAll, // Only one can expand at a time
                      //     spaceBetweenItem:
                      //         0, // Spacing between tiles
                      //     children: [
                      //       // Paycheck Tile 1
                      //       ExpansionTileItem(
                      //         initiallyExpanded: true,
                      //         trailing: Row(
                      //           mainAxisSize:
                      //               MainAxisSize.min,
                      //           children: [
                      //             Text(
                      //               "\$${(totalPrice * tnTax).toStringAsFixed(2)}",
                      //               style: Theme.of(context)
                      //                   .textTheme
                      //                   .titleSmall,
                      //             ),
                      //             gapW12,
                      //             const Icon(
                      //               CupertinoIcons
                      //                   .chevron_down,
                      //               size: 18,
                      //             ),
                      //           ],
                      //         ),
                      //         childrenPadding:
                      //             EdgeInsets.zero,
                      //         expendedBorderColor:
                      //             Colors.transparent,
                      //         title: const Text("Taxes"),
                      //         leading: const Icon(
                      //             CupertinoIcons.list_dash),
                      //         children: [
                      //           ListTile(
                      //             title: Text(
                      //                 "9.75% X ${totalPrice.toStringAsFixed(2)}"),
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
                                    BorderRadius.circular(
                                        15)),
                            tileColor: Colors.white,
                            leading: const Icon(
                                CupertinoIcons
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
                        borderRadius:
                            BorderRadius.circular(15),
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
                     // Display the saved signature
            if (signature != null)
                      Container(
                        
                        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Padding(
                               padding: const EdgeInsets.all(16.0),
                               child: Text(
                                  "Nurse Signature",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                             ),
                            const SizedBox(height: 4),
                            Center( // Centers the image
                              child: Image.memory(
                                signature,
                                scale: 2,
                                // Ensures it scales properly
                              ),
                            ),
                             const SizedBox(height: 12),
                          ],
                        ),
                      ),

                      gapH20
              ],
            ),
          )),
        );
      });
}
