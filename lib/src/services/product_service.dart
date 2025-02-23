import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synthecure/src/domain/part.dart';
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';
import 'package:synthecure/src/domain/app_user.dart';
import 'package:synthecure/src/repositories/orders_repository.dart';
import 'package:synthecure/src/repositories/product_repository.dart';

part 'product_service.g.dart';

class ProductsService {
  ProductsService({required this.productRepository});

  final ProductRepository productRepository;

  Stream<List<Part>> _allProductsStream(UserID uid) =>
      productRepository.watchAllProducts().map(_sortProducts);

  Stream<List<Part>> productsTileModelStream(UserID uid) =>
      _allProductsStream(uid);

  /// Sort products alphabetically by name
  static List<Part> _sortProducts(List<Part> products) {
    products.sort((a, b) => a.part.compareTo(b.part)); // Alphabetical order
    return products;
  }
}

@riverpod
ProductsService productsService(ProductsServiceRef ref) {
  return ProductsService(
    productRepository: ref.watch(productRepositoryProvider),
  );
}

@riverpod
Stream<List<Part>> productsTileModelStream(ProductsTileModelStreamRef ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw AssertionError('User can\'t be null when fetching products');
  }
  final productsService = ref.watch(productsServiceProvider);

  return productsService.productsTileModelStream(user.uid);
}
