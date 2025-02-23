import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/domain/part.dart';
import 'package:synthecure/src/features/admin/products/product_hospitals.dart';
import 'package:synthecure/src/features/admin/users/accounts_view.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/services/product_service.dart';
import 'package:synthecure/src/widgets/list_items_builder.dart';

class AllProducts extends ConsumerWidget {
  const AllProducts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: const Text('Your Products'),
        trailing: GestureDetector(
          onTap: () {
            context.pushNamed(AppRoute.addProduct.name);
          },
          child: Icon(
            CupertinoIcons.add,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0),
        child: Consumer(
          builder: (context, ref, child) {
            final productsStream =
                ref.watch(productsTileModelStreamProvider);

              double screenWidth =
              MediaQuery.of(context).size.width;
              double aspectRatio = screenWidth /
                  700; // Adjust this factor as needed


            return GridItemsBuilder<Part>(
                childAspectRatio: aspectRatio,
                data: productsStream,
                itemBuilder: (context, model) =>
                    ProductGridItem(model: model));
          },
        ),
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
    return GestureDetector(
      onTap: () {
        ref.read(productPageProvider.notifier).state =
            model;

        context.pushNamed(
          AppRoute.productHospitals.name,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          Text(
            model.description,
            style: TextStyle(
                color: Colors.grey.shade600, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
