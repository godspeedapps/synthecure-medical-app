import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/controllers/product_controller.dart';
import 'package:synthecure/src/domain/part.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';

final productPartProvider =
    StateProvider.autoDispose<String>((ref) => '');

final productGtinProvider =
    StateProvider.autoDispose<String>((ref) => '');

final productDescriptionProvider =
    StateProvider.autoDispose<String>((ref) => '');

// *** END OF PAGE PROVIDERS ***

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key});

  @override
  ConsumerState<AddProductPage> createState() =>
      _AddProductPageState();
}

class _AddProductPageState
    extends ConsumerState<AddProductPage> {
  final _productPartNode = FocusNode();
  final _productGtinNode = FocusNode();
  final _productDescriptionNode = FocusNode();

  double tnTax = .0975;

  @override
  void dispose() {
    _productPartNode
        .dispose(); // ✅ Clean up focus node properly
    _productGtinNode.dispose();
    _productDescriptionNode
        .dispose(); // ✅ Clean up focus node properly
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      adminPartControllerProvider,
      (_, state) => state.showAlertDialogUpdate(context,
          title: "Product added!",
          message:
              "Your product has been successfully added."),
    );

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
          middle: Text("New Product",
              style:
                  Theme.of(context).textTheme.titleMedium),
          trailing: Consumer(builder: (context, ref, _) {
            final productPart =
                ref.watch(productPartProvider);

            final productGtin =
                ref.watch(productGtinProvider);

            final proudctDescription =
                ref.watch(productDescriptionProvider);

            final isFormValid =
                proudctDescription.isNotEmpty &&
                    productPart.isNotEmpty;

            final state =
                ref.watch(adminPartControllerProvider);

            return TextButton(
              onPressed: isFormValid && !state.isLoading
                  ? () async {
                      final product = Part(
                          lot: "",
                          quantity: 0,
                          description: proudctDescription,
                          part: productPart,
                          price: 0,
                          hospitals: [],
                          gtin: productGtin);

                      await ref
                          .read(adminPartControllerProvider
                              .notifier)
                          .addProduct(product: product);
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

                    FocusScope.of(context)
                        .requestFocus(_productPartNode);
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
                              productPartProvider.notifier)
                          .state = value,
                      onSubmitted: (value) {
                        _productDescriptionNode
                            .requestFocus();
                      },

                      focusNode: _productPartNode,
                      placeholder: 'Product Part #',
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
                        _productDescriptionNode);
                  },
                  title: Text('Description',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium),
                  trailing: SizedBox(
                    width:
                        225, // ✅ Adjust width for better alignment
                    child: CupertinoTextField(
                      // ✅ State Management Integration
                      onChanged: (value) => ref
                          .read(productDescriptionProvider
                              .notifier)
                          .state = value,
                      onSubmitted: (value) {
                        _productGtinNode.requestFocus();
                      },
                      focusNode: _productDescriptionNode,
                      placeholder: 'Bone Void Filler...',
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
                CupertinoListTile(
                  onTap: () {
                    // ✅ Request focus programmatically

                    FocusScope.of(context)
                        .requestFocus(_productGtinNode);
                  },
                  title: Text('GTIN',
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
                              productGtinProvider.notifier)
                          .state = value,

                      focusNode: _productGtinNode,
                      placeholder: 'GTIN #',
                      keyboardType: TextInputType.number,
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
              ],
            ),
          ),
          gapH12,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
