import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/controllers/hospital_controller.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/features/admin/hospitals/add_hospital.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';

class EditProducts extends ConsumerWidget {
  final Hospital model;
  const EditProducts({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final expandedTiles = ref.watch(expandedTilesProvider);


       ref.listen<AsyncValue>(
      adminHospitalControllerProvider,
      (_, state) {
        state.showAlertDialogUpdate(
            context,message: "${model.name}'s products have been successfully updated.", title: "Hospital updated!");
      },
    );


    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CupertinoNavigationBar(
        middle: Text("Edit Products"),

        // trailing: GestureDetector(

        //   onTap: () {
        //       context.pushNamed(
        //                 AppRoute.chooseProducts.name);
        //   },
        //   child: Icon(CupertinoIcons.add, color: Theme.of(context).primaryColor,))
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ListView(
            children: [
              gapH12,
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0),
                child: ListTile(
                    onTap: () async {
                      context.pushNamed(
                          AppRoute.chooseProducts.name);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15)),
                    tileColor: Colors.white,
                    leading: const Icon(
                      CupertinoIcons.circle_grid_hex,
                      size: 25,
                    ),
                    title: Text(
                      "Change/Add Products",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall,
                    ),
                    trailing:
                        const CupertinoListTileChevron()),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final products =
                      ref.watch(selectedProductsProvider);

                  return Container(
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
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: Text(
                            "Hospital Prices",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall,
                          ),
                        ),
                        gapH12,
                        ExpansionTileGroup(
                          toggleType: ToggleType
                              .expandOnlyCurrent, // Only one can expand at a time
                          spaceBetweenItem:
                              0, // No spacing between tiles
                          children: products
                              .asMap()
                              .entries
                              .map((entry) {
                            // Iterating over all parts

                            final index = entry.key;
                            final part = entry.value;
                            final isExpanded = expandedTiles
                                .contains(index);

                            return ExpansionTileItem(
                              initiallyExpanded: isExpanded,
                              onExpansionChanged:
                                  (expanded) {
                                final updatedTiles =
                                    Set<int>.from(
                                        expandedTiles);
                                if (expanded) {
                                  updatedTiles.add(index);
                                } else {
                                  updatedTiles
                                      .remove(index);
                                }
                                ref
                                    .read(
                                        expandedTilesProvider
                                            .notifier)
                                    .state = updatedTiles;
                              },
                              trailing: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  AnimatedPrice(
                                      productId: part.id!,
                                      price: part.price),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    CupertinoIcons
                                        .chevron_down,
                                    size: 18,
                                  ),
                                ],
                              ),
                              childrenPadding:
                                  EdgeInsets.zero,
                              expendedBorderColor:
                                  Colors.transparent,
                              title: Row(
                                children: [
                                  Flexible(
                                      child: Text(part
                                          .description)),
                                  if (part.quantity > 1)
                                    Text(
                                      "  x${part.quantity}",
                                      style:
                                          const TextStyle(
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
                                      "CHANGE PRICE"),
                                  trailing: SizedBox(
                                    width:
                                        100, // Adjust width to fit your design

                                    child: TextField(
                                      controller: TextEditingController(
                                          text: part.price !=
                                                  0
                                              ? part.price
                                                  .toString()
                                              : null), // Set initial price value
                                      onChanged:
                                          (newPrice) {
                                        // You can add logic to update the price when the user changes the value
                                        // For example, using Riverpod or a similar state management system
                                        // Update the part with the new price (after parsing it to a number)
                                      },
                                      onSubmitted: (value) {
                                        ref
                                            .read(updatedProductsProvider
                                                .notifier)
                                            .updateProducts(
                                                <String>{part.id!});

                                        ref
                                            .read(selectedProductsProvider
                                                .notifier)
                                            .updateProductPrice(
                                                part.id!,
                                                double.parse(
                                                    value));

                                        // Automatically clear updated Iafter 1 second
                                        Future.delayed(
                                            const Duration(
                                                seconds: 1),
                                            () {
                                          ref
                                              .read(updatedProductsProvider
                                                  .notifier)
                                              .clear();
                                        });
                                      },
                                      keyboardType:
                                          TextInputType
                                              .numberWithOptions(
                                                  signed:
                                                      true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .allow(RegExp(
                                                r'^\d+\.?\d{0,4}'))
                                      ],
                                      decoration:
                                          InputDecoration(
                                        hintText: "Enter",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        10)),
                                      ),
                                    ),
                                  ),
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
                                  trailing: IconButton(
                                    icon: const Icon(
                                      CupertinoIcons
                                          .delete_simple,
                                      color: CupertinoColors
                                          .destructiveRed,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(
                                              selectedProductsProvider
                                                  .notifier)
                                          .toggleProductSelection(
                                              part);
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(), // Convert map result back to a list
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          Positioned(
            bottom: 25,
            child: Consumer(
              builder: (context, ref, child) {
                final products =
                    ref.watch(selectedProductsProvider);

                final state = ref
                    .watch(adminHospitalControllerProvider);

                return 
                      !state.isLoading
                    ? TextButton(
                        onPressed: 
                        
                        products.isNotEmpty
                        ? () async {
                          print(products);

                          await ref
                              .read(
                                  adminHospitalControllerProvider
                                      .notifier)
                              .updateHospitalProducts(
                                  hospital: model,
                                  updatedProducts:
                                      products);
                        } : null,
                        child: Text(
                          "Submit Changes",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: products
                                            .isNotEmpty &&
                                        products.every(
                                            (product) =>
                                                product
                                                    .price >
                                                0)
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                    : Colors.grey,
                              ),
                        ),
                      )
                    : CupertinoActivityIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }
}
