import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:synthecure/src/controllers/doctor_controller.dart';
import 'package:synthecure/src/controllers/hospital_controller.dart';
import 'package:synthecure/src/controllers/product_controller.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/domain/part.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';

final productPageProvider =
    StateProvider<Part?>((ref) => null);

/// The main UI widgetimport 'package:flutter/material.dart';

class ProductHospitals extends ConsumerStatefulWidget {
  const ProductHospitals({super.key});

  @override
  ProductHospitalsState createState() =>
      ProductHospitalsState();
}

class ProductHospitalsState
    extends ConsumerState<ProductHospitals> {
  // Declare the FocusNode and TextEditingController
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController =
      TextEditingController();

  late List<HospitalInfo> _hospitals = [];

  @override
  void initState() {
    _hospitals = ref
        .read(productPageProvider)!
        .hospitals; // Initialize from model
    super.initState();
  } // Store hospitals locally

  @override
  void dispose() {
    // Dispose of the focus node and controller when the widget is disposed
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Function to filter hospitals based on search query
  List<HospitalInfo> getFilteredHospitals(String query) {
    if (query.isEmpty) return _hospitals;

    return _hospitals
        .where((hospital) => hospital.name
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(productPageProvider);

    ref.listen<AsyncValue>(adminHospitalControllerProvider,
        (_, state) {
      state.showAlertDialogUpdate(context,
          title: "Product updated!",
          message:
              "New price has been attached to ${model!.part}");
    });

    ref.listen<AsyncValue>(
        adminHospitalRemoveProductControllerProvider,
        (_, state) {
      state.showAlertDialogUpdate(context,
          title: "Product removed!",
          message:
              "${model!.part} has been removed from hospital");
    });


        ref.listen<AsyncValue>(
        adminPartDeleteControllerProvider,
        (_, state) {
      state.showAlertDialogDelete(context,
          title: "Product removed!",
          message:
              "${model!.part} has been deleted!");
    });


    return Material(
      child: SuperScaffold(
        appBar: SuperAppBar(
          previousPageTitle: "Products",
          title: Text(model!.part),
          largeTitle: SuperLargeTitle(
            enabled: true,
            largeTitle: model!.part,
          ),
          searchBar: SuperSearchBar(
            searchController:
                _searchController, // Attach the controller
            searchFocusNode:
                _searchFocusNode, // Attach the FocusNode
            onSubmitted: (value) {
              _searchFocusNode.requestFocus();
            },
            onChanged: (query) {
              setState(() {});
            },
            resultBehavior:
                SearchBarResultBehavior.visibleOnInput,
            searchResult: Material(
              child: CustomScrollView(
                slivers: [
                  SliverList.builder(
                    itemCount: getFilteredHospitals(
                            _searchController.text)
                        .length,
                    itemBuilder: (context, index) {
                      final hospital = getFilteredHospitals(
                          _searchController.text)[index];
                      return HospitalTile(model: hospital);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey
                        .withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(15)),
                margin: EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.description,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    Text(model.gtin),
                    Row(
                    
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "#${model.id!}",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color: CupertinoColors
                                      .systemGrey),
                        ),
                        IconButton(
                            onPressed: () {
                              showCupertinoDialog(
                                  context: context,
                                  builder: (context) =>
                                      CupertinoAlertDialog(
                                        title: Text(
                                            'Delete Product?'),
                                        content: Text(
                                            "Are you sure you want to delete ${ref.read(productPageProvider)!.part}? Reps will not have access to this product anymore"),
                                        actions: [
                                          CupertinoDialogAction(
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context),
                                            child: const Text(
                                                'Cancel'),
                                          ),
                                          Consumer(
                                            builder:
                                                (context,
                                                    ref,
                                                    child) {
                                              final state =
                                                  ref.watch(
                                                      adminPartDeleteControllerProvider);

                                              final product =
                                                  ref.watch(
                                                      productPageProvider);

                                              return CupertinoDialogAction(
                                                isDestructiveAction:
                                                    true,
                                                onPressed: state
                                                        .isLoading
                                                    ? null // Disable button during loading
                                                    : () async {
                                                        await ref.read(adminPartDeleteControllerProvider.notifier).deleteProduct(part: product!);
                                                      },
                                                child: state
                                                        .isLoading
                                                    ? const CupertinoActivityIndicator() // Show loader
                                                    : const Text(
                                                        'Delete'), // Default text
                                              );
                                            },
                                          ),
                                        ],
                                      ));
                            },
                            icon: Icon(
                              CupertinoIcons.trash,
                              size: 20,
                              color: CupertinoColors
                                  .destructiveRed,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SliverList.builder(
              itemBuilder: (context, index) {
                return HospitalTile(
                    model: model.hospitals[index]);
              },
              itemCount: model.hospitals.length,
            )

            // Consumer(
            //   builder: (context, ref, child) {
            //     final hospitalStream = ref.watch(
            //         hospitalsTileModelStreamProvider);

            //     return SliverListItemsBuilder<Hospital>(
            //       data: hospitalStream,
            //       title: "No hospitals found",
            //       message: "Try searching again ⤴️",
            //       itemBuilder: (context, model) =>
            //           HospitalTile(model: model),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

String getHospitalInitials(String name) {
  List<String> words =
      name.trim().split(RegExp(r'\s+')); // Split by spaces
  if (words.length >= 2) {
    return words[0][0].toUpperCase() +
        words[1][0]
            .toUpperCase(); // First letter of first two words
  } else if (words.isNotEmpty) {
    return words[0]
        .substring(0, min(2, words[0].length))
        .toUpperCase(); // First two letters of a single word
  }
  return ""; // Default empty string for safety
}

class HospitalTile extends ConsumerWidget {
  final HospitalInfo model;

  const HospitalTile({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      trailing: IconButton(
          onPressed: () {
            showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                      title: Text('Remove Product?'),
                      content: Text(
                          "Are you sure you want to remove ${ref.read(productPageProvider)!.part} for ${model.name}? Reps will not have access to this product anymore"),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final state = ref.watch(
                                adminHospitalRemoveProductControllerProvider);

                            final product = ref
                                .watch(productPageProvider);

                            return CupertinoDialogAction(
                              isDestructiveAction: true,
                              onPressed: state.isLoading
                                  ? null // Disable button during loading
                                  : () async {
                                      await ref
                                          .read(
                                              adminHospitalRemoveProductControllerProvider
                                                  .notifier)
                                          .deleteProductHospitalRelationship(
                                              hospital:
                                                  Hospital(
                                                id: model
                                                    .id,
                                                name: model
                                                    .name,
                                              ),
                                              productToDelete:
                                                  product!.copyWith(
                                                      price:
                                                          model.price,
                                                      hospitals: []));
                                    },
                              child: state.isLoading
                                  ? const CupertinoActivityIndicator() // Show loader
                                  : const Text(
                                      'Remove'), // Default text
                            );
                          },
                        ),
                      ],
                    ));
          },
          icon: Icon(
            CupertinoIcons.minus_circle,
            size: 20,
            color: CupertinoColors.destructiveRed,
          )),
      onTap: () => _changePriceDialog(context),
      tileColor: Colors.white,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context)
            .colorScheme
            .primary
            .withOpacity(0.1),
        radius: 35,
        child: Text(
          getHospitalInitials(model.name),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 18,
          ),
        ),
      ),
      title: Text(
        model.name,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text("\$${model.price.toString()}",
          style: Theme.of(context).textTheme.titleSmall),
    );
  }

  void _changePriceDialog(BuildContext context) {
    TextEditingController priceController =
        TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (context) => Column(
        children: [
          SizedBox(
            height:
                MediaQuery.of(context).size.height / 3 - 50,
          ),
          SingleChildScrollView(
            child: CupertinoAlertDialog(
              title: Text("Change Product Price"),
              content: Column(
                children: [
                  SizedBox(height: 10),
                  Text(model.name),
                  SizedBox(height: 20),
                  CupertinoTextField(
                    controller: priceController,
                    placeholder: "Enter Price",
                    padding: EdgeInsets.all(12),
                    keyboardType:
                        TextInputType.numberWithOptions(
                            decimal:
                                true), // Allow decimals
                    decoration: BoxDecoration(
                      color: CupertinoColors
                          .white, // Background color
                      borderRadius: BorderRadius.circular(
                          12), // Rounded corners
                    ),
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text("Cancel"),
                  onPressed: () =>
                      Navigator.of(context).pop(),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(
                        adminHospitalControllerProvider);

                    final product =
                        ref.watch(productPageProvider);

                    return CupertinoDialogAction(
                      onPressed: !state.isLoading
                          ? () {
                              final enteredPrice =
                                  priceController.text
                                      .trim();
                              if (enteredPrice.isNotEmpty) {
                                // Assuming you have a method to update the price
                                final price =
                                    double.tryParse(
                                        enteredPrice);
                                if (price != null) {
                                  ref
                                      .read(
                                          adminHospitalControllerProvider
                                              .notifier)
                                      .updateSingleProductPrice(
                                          hospital: Hospital(
                                              id: model.id,
                                              name: model
                                                  .name),
                                          updatedProduct:
                                              product!.copyWith(
                                                  price:
                                                      price));
                                }
                              }
                            }
                          : null,
                      child: !state.isLoading
                          ? Text("Change Price")
                          : CupertinoActivityIndicator(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
