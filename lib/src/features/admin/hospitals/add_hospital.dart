import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/controllers/hospital_controller.dart';
import 'package:synthecure/src/domain/doctor.dart';
import 'package:synthecure/src/domain/hospital.dart';
import 'package:synthecure/src/domain/part.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';

//*** GENERAL PROVIDERS FOR PAGE */

// Define a provider for managing the list of selected doctors
final selectedDoctorsProvider = StateNotifierProvider<
    SelectedDoctorsNotifier, List<Doctor>>(
  (ref) => SelectedDoctorsNotifier(),
);

class SelectedDoctorsNotifier
    extends StateNotifier<List<Doctor>> {
  SelectedDoctorsNotifier() : super([]);

  // Add or remove a doctor
 // Add or remove a Product
  void toggleDoctorSelection(Doctor doctor) {
    if (state.any((item) => item.id == doctor.id)) {
      // Remove the product by id
      state = state
          .where((item) => item.id != doctor.id)
          .toList();
    } else {
      // Add the product with a modified price (copying and changing only the price)
      state = [...state, doctor];
    }
  }

   // Set the initial list of doctors
  void setDoctors(List<Doctor> doctors) {
    state = doctors;
  }

  // Clear all selected doctors
  void clear() {
    state = [];
  }
}

final selectedProductsProvider = StateNotifierProvider<
    SelectedProductsNotifier, List<Part>>(
  (ref) => SelectedProductsNotifier(),
);

class SelectedProductsNotifier
    extends StateNotifier<List<Part>> {
  SelectedProductsNotifier() : super([]);

  // Add or remove a Product
  void toggleProductSelection(Part part) {
    if (state.any((item) => item.id == part.id)) {
      // Remove the product by id
      state = state
          .where((item) => item.id != part.id)
          .toList();
    } else {
      // Add the product with a modified price (copying and changing only the price)
      state = [...state, part];
    }
  }

     // Set the initial list of doctors
  void setProducts(List<Part> products) {
    state = products;
  }

  // Change the price of a selected product by id
  void updateProductPrice(
      String productId, double newPrice) {
    state = state.map((item) {
      if (item.id == productId) {
        return item.copyWith(
            price: newPrice); // Update the price
      }
      return item; // Keep the other products unchanged
    }).toList();
  }

  // Clear all selected doctors
  void clear() {
    state = [];
  }
}

final priceUpdatedProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final expandedTilesProvider =
    StateProvider<Set<int>>((ref) => {});

final hospitalNameProvider =
    StateProvider.autoDispose<String>((ref) => '');

final hospitalEmailProvider =
    StateProvider.autoDispose<String>((ref) => '');

// *** END OF PAGE PROVIDERS ***

class AddHospitalPage extends ConsumerStatefulWidget {
  const AddHospitalPage({super.key});

  @override
  ConsumerState<AddHospitalPage> createState() =>
      _AddHospitalPageState();
}

class _AddHospitalPageState
    extends ConsumerState<AddHospitalPage> {
  Doctor? _selectedDoctor;

  final _hospitalNameFocusNode = FocusNode();
  final _hospitalEmailFocusNode = FocusNode();

  double tnTax = .0975;

  @override
  void dispose() {
    _hospitalNameFocusNode
        .dispose(); // ✅ Clean up focus node properly
    _hospitalEmailFocusNode
        .dispose(); // ✅ Clean up focus node properly
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expandedTiles = ref.watch(expandedTilesProvider);

    ref.listen<AsyncValue>(
      adminHospitalControllerProvider,
      (_, state) => state.showAlertDialogAddHospital(
          context, ref.read(hospitalNameProvider)),
    );

    return Scaffold(
      appBar: CupertinoNavigationBar(
          backgroundColor: Colors.white,
          leading: TextButton(
              onPressed: () {
                ref
                    .read(selectedDoctorsProvider.notifier)
                    .clear();

                ref
                    .read(selectedProductsProvider.notifier)
                    .clear();

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
          middle: Text("New Hospital",
              style:
                  Theme.of(context).textTheme.titleMedium),
          trailing: Consumer(builder: (context, ref, _) {
            final hospitalName =
                ref.watch(hospitalNameProvider);

            final hospitalEmail =
                ref.watch(hospitalEmailProvider);

            final selectedDoctors =
                ref.watch(selectedDoctorsProvider);

            final selectedProducts =
                ref.watch(selectedProductsProvider);

            final isFormValid =
                selectedDoctors.isNotEmpty &&
                    hospitalEmail.isNotEmpty &&
                    hospitalName.isNotEmpty &&
                    selectedProducts.isNotEmpty && selectedProducts.every((product) =>  product.price > 0);

            final state =
                ref.watch(adminHospitalControllerProvider);

            return TextButton(
              onPressed: isFormValid && !state.isLoading
                  ? () async {
                 

                      final createdHospital = Hospital(
                        id: "",
                        name: hospitalName,
                        email: hospitalEmail,
                        products: selectedProducts,
                        doctors: selectedDoctors
                            .map((doctor) => doctor
                                .copyWith(hospitals: []))
                            .toList(),
                      );

                

                      await ref
                          .read(
                              adminHospitalControllerProvider
                                  .notifier)
                          .addHospital(
                              hospital: createdHospital);
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
                // Patient ID Tile
                CupertinoListTile(
                  onTap: () {
                    // ✅ Request focus programmatically

                    FocusScope.of(context).requestFocus(
                        _hospitalNameFocusNode);
                  },
                  title: Text('Name',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium),
                  trailing: SizedBox(
                    width:
                        225, // ✅ Adjust width for better alignment
                    child: CupertinoTextField(
                      // ✅ State Management Integration
                      onChanged: (value) => ref
                          .read(
                              hospitalNameProvider.notifier)
                          .state = value,
                      onSubmitted: (value) {
                        _hospitalEmailFocusNode
                            .requestFocus();
                      },

                      focusNode: _hospitalNameFocusNode,
                      placeholder: 'Hospital Name',
                      // keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      textInputAction: TextInputAction.next,
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
                ),
                CupertinoListTile(
                  onTap: () {
                    // ✅ Request focus programmatically

                    FocusScope.of(context).requestFocus(
                        _hospitalEmailFocusNode);
                  },
                  title: Text('Email',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium),
                  trailing: SizedBox(
                    width:
                        225, // ✅ Adjust width for better alignment
                    child: CupertinoTextField(
                      // ✅ State Management Integration
                      onChanged: (value) => ref
                          .read(hospitalEmailProvider
                              .notifier)
                          .state = value,

                      focusNode: _hospitalEmailFocusNode,
                      placeholder: 'Hospital Email',
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
                ),

                // Doctor Picker Tile
                CupertinoListTile(
                    title: Text('Doctors',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium),
                    trailing: const DoctorChevron(),
                    onTap: () {
                      context.pushNamed(
                          AppRoute.chooseDoctors.name);
                    }),
              ],
            ),
          ),
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
                  "Add Products",
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall,
                ),
                trailing: const CupertinoListTileChevron()),
          ),
          Consumer(
            builder: (context, ref, child) {
              final products =
                  ref.watch(selectedProductsProvider);

              return Container(
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
                        final isExpanded =
                            expandedTiles.contains(index);

                        return ExpansionTileItem(
                          initiallyExpanded: isExpanded,
                          onExpansionChanged: (expanded) {
                            final updatedTiles =
                                Set<int>.from(
                                    expandedTiles);
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
                                  child: Text(
                                      part.description)),
                              if (part.quantity > 1)
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
                                  "CHANGE PRICE"),
                              trailing: SizedBox(
                                width:
                                    100, // Adjust width to fit your design

                                child: TextField(
                                  controller:
                                      TextEditingController(
                                          text: part.price !=
                                                  0
                                              ? part.price
                                                  .toString()
                                              : null), // Set initial price value
                                  onChanged: (newPrice) {
                                    // You can add logic to update the price when the user changes the value
                                    // For example, using Riverpod or a similar state management system
                                    // Update the part with the new price (after parsing it to a number)
                                  },
                                  onSubmitted: (value) {
                                    ref
                                        .read(
                                            updatedProductsProvider
                                                .notifier)
                                        .updateProducts(
                                            <String>{part.id!});

                                    ref
                                        .read(
                                            selectedProductsProvider
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
                                          .read(
                                              updatedProductsProvider
                                                  .notifier)
                                          .clear();
                                    });
                                  },
                                  keyboardType: TextInputType
                                      .numberWithOptions(
                                          signed: true),
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
                              subtitle:
                                  const Text("PART NUMBER"),
                            ),
                            ListTile(
                              title: Text(part.gtin),
                              subtitle: const Text("GTIN"),
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
          const SizedBox(height: 8),
        ],
      ),
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

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        begin: Colors.white.withOpacity(0.1),
        end: updatedProducts.contains(productId)
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
      for (var part in hospital.products!)
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
    final index = state.indexWhere((existingProduct) =>
        existingProduct.id == product.id);

    if (index != -1) {
      // Product exists, increment its quantity
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            state[i]
                .copyWith(quantity: state[i].quantity + 1)
          else
            state[i]
      ];
    } else {
      // Product doesn't exist, add it with default quantity
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

class DoctorChevron extends ConsumerWidget {
  /// Creates a typical widget used to denote that a `CupertinoListTile` is a
  /// button with action.
  const DoctorChevron({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDoctors =
        ref.watch(selectedDoctorsProvider);

    // Determine the hospital display text
    String doctorsText = "No hospitals";

    if (selectedDoctors.isNotEmpty) {
      final randomHospital = (selectedDoctors..shuffle())
          .first; // Pick a random hospital
      final othersCount = selectedDoctors.length - 1;
      doctorsText = othersCount > 0
          ? "Dr. ${randomHospital.name} and $othersCount others"
          : "Dr. ${randomHospital.name}";
    }

    return doctorsText == "No hospitals"
        ? Icon(
            CupertinoIcons.right_chevron,
            size: CupertinoTheme.of(context)
                .textTheme
                .textStyle
                .fontSize,
            color: CupertinoColors.systemGrey2
                .resolveFrom(context),
          )
        : Text(doctorsText,
            style: Theme.of(context).textTheme.bodySmall);
  }
}
