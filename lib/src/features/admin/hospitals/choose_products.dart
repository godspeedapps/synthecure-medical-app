import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/constants/app_sizes.dart';
import 'package:synthecure/src/domain/part.dart';
import 'package:synthecure/src/features/admin/hospitals/add_hospital.dart';
import 'package:synthecure/src/features/admin/users/accounts_view.dart';
import 'package:synthecure/src/services/product_service.dart';
import 'package:synthecure/src/widgets/list_items_builder.dart';

class ChooseProducts extends ConsumerWidget {
  const ChooseProducts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: const Text('Choose Products'),
        // trailing: Icon(CupertinoIcons.add, color: Theme.of(context).primaryColor,),
      ),
      backgroundColor: Colors.white,
      body: Consumer(
        builder: (context, ref, child) {
          final productsStream =
              ref.watch(productsTileModelStreamProvider);

          // Get the screen width and calculate the aspect ratio dynamically
          double screenWidth =
              MediaQuery.of(context).size.width;
          double aspectRatio = screenWidth /
              700; // Adjust this factor as needed

          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0),
            child: Column(
              children: [
               
                Expanded(
                  child: GridItemsBuilder<Part>(
                    
                      childAspectRatio: aspectRatio,
                      data: productsStream,
                      itemBuilder: (context, model) =>
                          ProductGridItem(model: model)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProductGridItem extends ConsumerWidget {
  const ProductGridItem({
    super.key,
    required this.model,
  });

  final Part model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProducts =
        ref.watch(selectedProductsProvider);

    final isSelected = selectedProducts.any((part) => part.id == model.id);

    return GestureDetector(
      onTap: () {
        ref
            .read(selectedProductsProvider.notifier)
            .toggleProductSelection(model);
      },
      child: Container(
        decoration: BoxDecoration(
            color: !isSelected
                ? Colors.transparent
                : Theme.of(context)
                    .primaryColor
                    .withOpacity(0.1),
            borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.all(4.0),
     
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Opacity(
                opacity: .5,
                child: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    radius: 50,
                    child: const LottieAvatar())),
            const SizedBox(height: 8),
            Text(
              model.part,
              style: const TextStyle(
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                model.description,
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
