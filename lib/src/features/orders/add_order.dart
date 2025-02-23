import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';
import 'package:synthecure/src/repositories/orders_repository.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/domain/part.dart';
import 'package:synthecure/src/features/orders/edit_order_screen/edit_order_screen_controller.dart';
import 'package:synthecure/src/utils/alert_dialogs.dart';
import 'package:synthecure/src/utils/case_screenshot.dart';
import 'package:synthecure/src/utils/snackbars.dart';

final expandedTilesProvider =
    StateProvider<Set<int>>((ref) => {});

final patientIdProvider =
    StateProvider.autoDispose<String>((ref) => '');

class CaseFormPage extends ConsumerStatefulWidget {
  const CaseFormPage({super.key});

  @override
  ConsumerState<CaseFormPage> createState() =>
      _CaseFormPageState();
}

class _CaseFormPageState
    extends ConsumerState<CaseFormPage> {
  Hospital? _selectedHospital;
  Doctor? _selectedDoctor;
  DateTime _selectedDate = DateTime.now();

  bool isRestock = false;
  final TextEditingController _patientIdController =
      TextEditingController();

  final TextEditingController _notesController =
      TextEditingController();
  final _patientIdFocusNode = FocusNode();

  double tnTax = .0975;

  @override
  void dispose() {
    _patientIdFocusNode
        .dispose(); // ✅ Clean up focus node properly
    super.dispose();
  }

  Part? getMatchingPart(
      List<Part> products, String inputPart) {
    try {
      // Use firstWhere to find the matching part
      return products.firstWhere(
          (product) => product.part == inputPart);
    } catch (e) {
      // Return null if no matching part is found
      return null;
    }
  }

  Part? getMatchingPartByGtin(
      List<Part> products, String inputGtin) {
    try {
      print(products);
      // Use firstWhere to find the matching part by GTIN
      return products.firstWhere(
          (product) => product.gtin == inputGtin);
    } catch (e) {
      // Return null if no matching part is found
      return null;
    }
  }

  Future<void> _showMaterialDateTimePicker(
      BuildContext context) async {
    DateTime initialDate = _selectedDate;

    // ✅ Step 1: Show the Date Picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // ✅ Step 2: Show the Time Picker after selecting date
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      // ✅ Step 3: Combine Date and Time
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _showHospitalPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            // ✅ StreamBuilder added to listen for the stream
            Expanded(
              child: StreamBuilder<List<Hospital>>(
                stream:
                    ref.read(usersHospitalQueryProvider),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child:
                            CupertinoActivityIndicator());
                  }
                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                        child:
                            Text('No hospitals available'));
                  }

                  final hospitalList = snapshot.data!;

                  WidgetsBinding.instance
                      .addPostFrameCallback((_) {
                    setState(() {
                      _selectedHospital ??= hospitalList[0];
                    });
                  });

                  final int initialIndex =
                      _selectedHospital != null
                          ? hospitalList.indexWhere(
                              (hospital) =>
                                  hospital.name ==
                                  _selectedHospital!.name)
                          : 0;

                  FixedExtentScrollController
                      scrollController =
                      FixedExtentScrollController(
                          initialItem: initialIndex);

                  return CupertinoPicker(
                    scrollController: scrollController,
                    itemExtent: 50,
                    onSelectedItemChanged: (index) {
                      setState(() => _selectedHospital =
                          hospitalList[index]);

                      if (ref
                          .read(productProvider)
                          .isNotEmpty) {
                        // ✅ Trigger price update
                        ref
                            .read(productProvider.notifier)
                            .updatePricesForNewHospital(
                                hospitalList[index]);

                        showCustomSnackbar(context,
                            "*Product prices updated ");
                      }
                    },
                    children: hospitalList
                        .map((hospital) => Center(
                            child: Text(hospital.name)))
                        .toList(),
                  );
                },
              ),
            ),
            // ✅ Done Button
            CupertinoButton(
              child: const Text('Done'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show Doctor Picker
  void _showDoctorPicker() {
    final doctorList = _selectedHospital!.doctors!;

    print(doctorList);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedDoctor ??= doctorList[0];
      });
    });

    final int initialIndex = _selectedDoctor != null
        ? doctorList.indexWhere((doctor) =>
            doctor.name == _selectedDoctor!.name)
        : 0;

    FixedExtentScrollController scrollController =
        FixedExtentScrollController(
            initialItem: initialIndex);

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            // ✅ StreamBuilder added to listen for the stream
            Expanded(
              child: CupertinoPicker(
                itemExtent: 50,
                scrollController: scrollController,
                onSelectedItemChanged: (index) {
                  setState(() =>
                      _selectedDoctor = doctorList[index]);
                },
                children: doctorList
                    .map((doctor) => Center(
                        child: Text("Dr. ${doctor.name}")))
                    .toList(),
              ),
            ),
            // ✅ Done Button
            CupertinoButton(
              child: const Text('Done'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expandedTiles = ref.watch(expandedTilesProvider);

    final products = ref.watch(productProvider);
    final totalPrice = ref
        .watch(productProvider.notifier)
        .totalProductsPrice;

    return Scaffold(
      appBar: CupertinoNavigationBar(
          backgroundColor: Colors.white,
          leading: TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text(
                "Close",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .primary),
              )),
          middle: Text("New Case Sheet",
              style:
                  Theme.of(context).textTheme.titleMedium),
          trailing: Consumer(builder: (context, ref, _) {
            final patientId = ref.watch(patientIdProvider);
            final isFormValid = _selectedHospital != null &&
                _selectedDoctor != null &&
                patientId.trim().isNotEmpty &&
                products.isNotEmpty;

            final state =
                ref.watch(editJobScreenControllerProvider);

            return TextButton(
              onPressed: isFormValid && !state.isLoading
                  ? () async {
                      final order = {
                        "date": _selectedDate,
                        "doctor": _selectedDoctor,
                        "hospital": _selectedHospital,
                        "patient": patientId,
                        "notes":
                            _notesController.text.trim(),
                        "isRestock" : isRestock
                      };

                      final createdOrder = await ref
                          .read(
                              editJobScreenControllerProvider
                                  .notifier)
                          .submit(
                              data: order,
                              products: products,
                              isClosed: false);

                      if (createdOrder != null &&
                          context.mounted) {
                        final choice = await showAlertDialog(
                            context: context,
                            title:
                                "Would you like to go ahead and deliver this case sheet?",
                            cancelActionText: "Later",
                            defaultActionText: "Deliver");

                        if (choice == true &&
                            context.mounted) {
                          showSignatureBox(
                              context,
                              ref,
                              createdOrder,
                              totalPrice,
                              tnTax);
                        } else {
                          if (context.mounted) {
                            context.pop();
                            context.pop();
                          }
                        }
                      } else if (context.mounted) {
                        showErrorSnackbar(context,
                            "Couldn't add case sheet, Try again!"); // Show error message
                      }
                    }
                  : null, // ✅ Disable when invalid

              child: state.isLoading
                  ? const CupertinoActivityIndicator()
                  : Text(
                      "Submit",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            color: isFormValid
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                : Colors.grey,
                          ),
                    ),
            );
          })),
      body: ListView(
        children: [
          gapH16,
          SafeArea(
            child: CupertinoFormSection.insetGrouped(
              children: [
                // Date Picker Tile

                CupertinoListTile(
                  title: Text('Date',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium),
                  trailing: Text(
                    '${DateFormat.yMd().format(_selectedDate)} at ${DateFormat.jm().format(_selectedDate)}',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall,
                  ),
                  onTap: () async =>
                      await _showMaterialDateTimePicker(
                          context),
                ),

                // Hospital Picker Tile
                CupertinoListTile(
                  title: Text('Hospital',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium),
                  trailing: _selectedHospital != null
                      ? Text(
                          _selectedHospital!.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall,
                        )
                      : const CupertinoListTileChevron(),
                  onTap: _showHospitalPicker,
                ),

                // Doctor Picker Tile
                CupertinoListTile(
                    title: Text('Doctor',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium),
                    trailing: _selectedDoctor != null
                        ? Text(
                            _selectedDoctor!.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall,
                          )
                        : const CupertinoListTileChevron(),
                    onTap: _selectedHospital != null
                        ? _showDoctorPicker
                        : () => showAlertDialog(
                            context: context,
                            title:
                                "You must select a hospital before choosing a Doctor",
                            defaultActionText: "Close")),

                // Patient ID Tile
                CupertinoListTile(
                  onTap: () {
                    // ✅ Request focus programmatically

                    FocusScope.of(context)
                        .requestFocus(_patientIdFocusNode);
                  },
                  title: Text('Case ID',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium),
                  trailing: SizedBox(
                    width:
                        150, // ✅ Adjust width for better alignment
                    child: CupertinoTextField(
                      // ✅ State Management Integration
                      onChanged: (value) => ref
                          .read(patientIdProvider.notifier)
                          .state = value,
                      controller: _patientIdController,
                      focusNode: _patientIdFocusNode,
                      placeholder: 'Enter Case ID',
                      // keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      textInputAction: TextInputAction.done,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall,
                      textAlign: TextAlign
                          .end, // ✅ Aligning text to the right for consistency
                      padding: EdgeInsets
                          .zero, // ✅ Removing internal padding
                      decoration: BoxDecoration(
                        // ✅ No border, no background
                        color: Colors.transparent,
                        border: Border.all(
                            color: Colors.transparent),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          gapH12,
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0),
            child: ListTile(
                onLongPress: () async {
                  if (_selectedHospital != null) {
                    await addProductDialog(
                        context, ref, _selectedHospital!);
                  } else {
                    showAlertDialog(
                        context: context,
                        title:
                            "You must select a hospital before adding Products",
                        defaultActionText: 'close');
                  }
                },
                onTap: () async {
                  if (_selectedHospital != null) {
                    String barcodeScanRes =
                        await FlutterBarcodeScanner
                            .scanBarcode(
                                '#87CEEB',
                                'cancel',
                                true,
                                ScanMode.BARCODE);

                    //*** GET INFO FROM SCAN ***

                    String lotNumber =
                        barcodeScanRes.substring(
                            barcodeScanRes.length - 8);
                    String gTin =
                        barcodeScanRes.substring(2, 16);

                    if (lotNumber.isNotEmpty &&
                        gTin.isNotEmpty) {
                      // *** ADD THE PRODUCT TO CART IF MATCHED ***

                      final matchingPart =
                          getMatchingPartByGtin(
                              _selectedHospital!.products!,
                              gTin);

                      if (matchingPart != null) {
                        ref
                            .read(productProvider.notifier)
                            .addProduct(matchingPart
                                .copyWith(lot: lotNumber));

                        if (context.mounted) {
                          showSuccessSnackbar(context,
                              "Part has been successfully added");
                        }
                      } else {
                        if (context.mounted) {
                          showErrorSnackbar(context,
                              "This part does not exist in your inventory, try again.");
                        }
                      }
                    }
                  } else {
                    showAlertDialog(
                        context: context,
                        title:
                            "You must select a hospital before adding Products",
                        defaultActionText: "Close");
                  }
                },
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15)),
                tileColor: Colors.white,
                leading: const Icon(
                  CupertinoIcons.barcode_viewfinder,
                  size: 30,
                ),
                title: Text(
                  "Add Products",
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall,
                ),
                trailing: const CupertinoListTileChevron()),
          ),
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  children:
                      products.asMap().entries.map((entry) {
                    // Iterating over all parts

                    final index = entry.key;
                    final part = entry.value;
                    final isExpanded =
                        expandedTiles.contains(index);

                    return ExpansionTileItem(
                      initiallyExpanded: isExpanded,
                      onExpansionChanged: (expanded) {
                        final updatedTiles =
                            Set<int>.from(expandedTiles);
                        if (expanded) {
                          updatedTiles.add(index);
                        } else {
                          updatedTiles.remove(index);
                        }
                        ref
                            .read(expandedTilesProvider
                                .notifier)
                            .state = updatedTiles;
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedPrice(
                              productId: part.id!,
                              price: part.price),
                          const SizedBox(width: 12),
                          const Icon(
                            CupertinoIcons.chevron_down,
                            size: 18,
                          ),
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
                          trailing: IconButton(
                            icon: const Icon(
                              CupertinoIcons.delete_simple,
                              color: CupertinoColors
                                  .destructiveRed,
                              size: 20,
                            ),
                            onPressed: () {
                              ref
                                  .read(productProvider
                                      .notifier)
                                  .deleteProduct(index);
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(part.part),
                          subtitle:
                              const Text("PART NUMBER"),
                          trailing: // ✅ Quantity Selector
                              Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (part.quantity > 1) {
                                    ref
                                        .read(
                                            productProvider
                                                .notifier)
                                        .changeQuantity(
                                            index,
                                            part.quantity -
                                                1);
                                  }
                                },
                                child: const Icon(
                                  CupertinoIcons
                                      .minus_circle,
                                  color: CupertinoColors
                                      .destructiveRed,
                                  size: 25,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets
                                    .symmetric(
                                    horizontal: 8.0),
                                child: Text(
                                  "${part.quantity}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(productProvider
                                          .notifier)
                                      .changeQuantity(
                                          index,
                                          part.quantity +
                                              1);
                                },
                                child: Icon(
                                  CupertinoIcons
                                      .add_circled,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          title: Text(part.gtin),
                          subtitle: const Text("GTIN"),
                        ),
                      ],
                    );
                  }).toList(), // Convert map result back to a list
                ),
                // if (products.isNotEmpty)
                //   ExpansionTileGroup(
                //       toggleType: ToggleType
                //           .expandOnlyCurrent, // Only one can expand at a time
                //       spaceBetweenItem:
                //           0, // Spacing between tiles
                //       children: [
                //         // Paycheck Tile 1
                //         ExpansionTileItem(
                //           trailing: Row(
                //             mainAxisSize: MainAxisSize.min,
                //             children: [
                //               AnimatedTaxAndTotal(text: "\$${(totalPrice * tnTax).toStringAsFixed(2)}",),
                //               gapW12,
                //               const Icon(
                //                 CupertinoIcons.chevron_down,
                //                 size: 18,
                //               ),
                //             ],
                //           ),
                //           childrenPadding: EdgeInsets.zero,
                //           expendedBorderColor:
                //               Colors.transparent,
                //           title: const Text("Taxes"),
                //           leading: const Icon(
                //               CupertinoIcons.list_dash),
                //           children: [
                //             ListTile(
                //               title: Text(
                //                   "9.75% X ${totalPrice.toStringAsFixed(2)}"),
                //               subtitle: const Text(
                //                   "TENNESSEE SALES TAX"),
                //             ),
                //           ],
                //         ),
                //       ]),
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
                      trailing: AnimatedTaxAndTotal(
                          text:
                              "\$${(totalPrice).toStringAsFixed(2)}")),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              tileColor: Colors.white,
              title: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notes",
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall,
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(
                    top: 4.0, bottom: 8.0),
                child: Column(
                  children: [
                    CupertinoTextField(
                    
                      placeholder: "Add your notes here...",
                      maxLength: 500, // ✅ Text limit of 250
                      padding: const EdgeInsets.all(12),
                      maxLines:
                          null, // ✅ Expanding text field
                      controller: _notesController,

                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors
                                .transparent), // ✅ No borders
                      ),
                      onChanged: (text) {
                        setState(
                            () {}); // ✅ Rebuild the widget to expand dynamically
                      },
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        Text("is Restock?", style:  Theme.of(context).textTheme.titleSmall,),
                   
                        Transform.scale(
                          scale: 1.2,
                          child: CupertinoCheckbox(
                              value: (isRestock),
                              onChanged: (value) {
                                setState(() {
                                  isRestock = value ?? false;
                                });
                              }),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.info_circle,
                  size: 15,
                  color: Theme.of(context).primaryColor,
                ),
                gapW8,
                Flexible(
                    child: Text(
                  "DO NOT INCLUDE PATIENT NAME",
                  style: TextStyle(
                      color: CupertinoColors.inactiveGray,
                      fontSize: 12),
                ))
              ],
            ),
          )
          // ✅ Character count indicator
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: Align(
          //     alignment: Alignment.bottomRight,
          //     child: Text(
          //       "${_notesController.text.length}/500",
          //       style: Theme.of(context).textTheme.bodySmall,
          //     ),),
          // )
        ],
      ),
    );
  }

  Future<void> addProductDialog(BuildContext context,
      WidgetRef ref, Hospital hospital) {
    // ✅ Declare the controllers
    final TextEditingController partController =
        TextEditingController();
    final TextEditingController lotController =
        TextEditingController();

    // ✅ Create a local state for button validation
    bool isFormValid() =>
        partController.text.isNotEmpty &&
        lotController.text.isNotEmpty;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text("Add Product",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Part Number Field
                CupertinoTextField(
                  autofocus: true,
                  controller: partController,
                  onChanged: (_) => setState(() {}),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  placeholder: "Part Number#",
                ),
                const SizedBox(height: 12),

                // ✅ Lot Number Field
                CupertinoTextField(
                  controller: lotController,
                  onChanged: (_) => setState(() {}),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  placeholder: "Lot Number#",
                ),
                const SizedBox(height: 16),

                // ✅ Save Button with Dynamic Disabling
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0),
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                    // ✅ Button is enabled only if both fields are filled
                    onPressed: isFormValid()
                        ? () {
                            // *** MATCHES A HOSPITAL PRODUCT

                            final matchingPart =
                                getMatchingPart(
                                    hospital.products!,
                                    partController.text);

                            if (matchingPart != null) {
                              // *** ADD TO THE CART LIST ***

                              ref
                                  .read(productProvider
                                      .notifier)
                                  .addProduct(
                                      matchingPart.copyWith(
                                          lot: lotController
                                              .text
                                              .trim()));

                              showSuccessSnackbar(context,
                                  "Part has been successfully added");

                              context.pop();
                            } else {
                              showErrorSnackbar(context,
                                  "This part does not exist in your inventory, try again.");
                            }
                          }
                        : null, // ✅ Disables button if fields are empty
                    child: Text('Save',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedPrice extends ConsumerWidget {
  final String productId;
  final double price;

  const AnimatedPrice({
    super.key,
    required this.productId,
    required this.price,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatedProducts =
        ref.watch(updatedProductsProvider);
    final isUpdated = updatedProducts.contains(productId);

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        begin: Colors.white.withOpacity(0.1),
        end: isUpdated
            ? Theme.of(context)
                .colorScheme
                .secondary
                .withOpacity(0.5)
            : Colors.white.withOpacity(0.1),
      ),
      duration: const Duration(milliseconds: 500),
      builder: (context, color, child) {
        return Container(
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.all(4.0),
          child: child,
        );
      },
      child: Text(
        "\$${price.toStringAsFixed(2)}",
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

class AnimatedTaxAndTotal extends ConsumerWidget {
  final String text;

  const AnimatedTaxAndTotal(
      {super.key, required this.text});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatedProducts =
        ref.watch(updatedProductsProvider);
    final isUpdated = updatedProducts.isNotEmpty;

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        begin: Colors.white.withOpacity(0.1),
        end: isUpdated
            ? Theme.of(context)
                .colorScheme
                .secondary
                .withOpacity(0.5)
            : Colors.white.withOpacity(0.1),
      ),
      duration: const Duration(milliseconds: 500),
      builder: (context, color, child) {
        return Container(
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.all(4.0),
          child: child,
        );
      },
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

// ✅ StateNotifier to Manage Products and Calculate Total Price
class ProductNotifier extends StateNotifier<List<Part>> {
  final Ref ref;

  ProductNotifier(this.ref) : super([]);

  double get totalProductsPrice => state.fold(
      0,
      (sum, product) =>
          sum +
          (product.price != 0
              ? product.price * product.quantity
              : 0));

  void updatePricesForNewHospital(Hospital hospital) {
    final updatedIds = <String>{};

    // Create a map of the hospital's products for quick lookup
    final hospitalProducts = {
      for (var part in hospital!.products!)
        part.id: part.price
    };

    state = state.where((product) {
      if (hospitalProducts.containsKey(product.id)) {
        final newPrice = hospitalProducts[product.id]!;
        if (product.price != newPrice) {
          updatedIds.add(product.id!);
          return true; // Retain the product as its price changes
        }
        return true; // Retain the product without changes
      }
      return false; // Remove product not in the hospital's list
    }).map((product) {
      // Update the price if it has changed
      final newPrice = hospitalProducts[product.id]!;
      return product.price != newPrice
          ? product.copyWith(price: newPrice)
          : product;
    }).toList();

    // Trigger animation

    // Update the updated products provider
    ref
        .read(updatedProductsProvider.notifier)
        .updateProducts(updatedIds);

    // Automatically clear updated IDs after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      ref.read(updatedProductsProvider.notifier).clear();
    });
  }

  void changeQuantity(int index, int newQuantity) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          state[i] =
              state[i].copyWith(quantity: newQuantity)
        else
          state[i]
    ];
  }

  void addProduct(Part product) {
    final index = state.indexWhere(
      (existingProduct) =>
          existingProduct.id == product.id &&
          existingProduct.lot ==
              product
                  .lot, // Match both Part ID and Lot Number
    );

    if (index != -1) {
      // Product with the same part number AND lot number exists, increment its quantity
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            state[i]
                .copyWith(quantity: state[i].quantity + 1)
          else
            state[i]
      ];
    } else {
      // If either part number or lot number is different, treat it as a new product
      state = [...state, product];
    }
  }

  // ✅ New delete method added
  void deleteProduct(int index) {
    state = List.from(state)..removeAt(index);
  }
}

// ✅ Riverpod Provider
final productProvider = StateNotifierProvider.autoDispose<
    ProductNotifier, List<Part>>((ref) {
  return ProductNotifier(ref);
});

class UpdatedProductsNotifier
    extends StateNotifier<Set<String>> {
  UpdatedProductsNotifier() : super({});

  // Add updated product IDs
  void updateProducts(Set<String> productIds) {
    state = {...state, ...productIds};
  }

  // Clear all updated products
  void clear() {
    state = {};
  }
}

// Provider for updated products
final updatedProductsProvider = StateNotifierProvider<
    UpdatedProductsNotifier, Set<String>>(
  (ref) => UpdatedProductsNotifier(),
);
