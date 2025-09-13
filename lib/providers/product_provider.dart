import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../db/database_helper.dart';

class ProductProvider extends ChangeNotifier {
  final String? currentUserId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _productsSubscription;

  List<Product> _products;
  List<Product> get products => _products;

  ProductProvider({this.currentUserId, List<Product> products = const []}) : _products = products {
    if (currentUserId != null) {
      print("✅ ProductProvider created for user: $currentUserId");
    } else {
      print("✅ ProductProvider created for logged-out user.");
    }
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }

  /// Sets up a real-time stream from Firestore to fetch and sync user's products.
  void fetchMyProducts() {
    if (currentUserId == null) {
      _products = [];
      notifyListeners();
      return;
    }

    _productsSubscription?.cancel();
    _productsSubscription = _firestore
        .collection('products')
        .where('ownerId', isEqualTo: currentUserId)
        .snapshots()
        .listen((snapshot) async {
      final firestoreProducts = snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
      _products = firestoreProducts;
      notifyListeners();

      // Update local cache
      await DBHelper.clearProducts();
      for (var product in _products) {
        await DBHelper.insertProduct(product);
      }
      print("🔄 Local cache synced with Firestore.");
    }, onError: (error) {
      print("Error fetching products: $error");
    });
  }

  /// Adds a new product to Firestore.
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).set(product.toJson());
  }

  /// Updates a product in Firestore.
  Future<void> updateProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).update(product.toJson());
  }

  /// Removes a product from Firestore.
  Future<void> removeProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  /// Exchanges two products between users via Firestore.
  Future<void> exchangeProducts(Product myProduct, Product otherProduct) async {
    final doc1 = _firestore.collection('products').doc(myProduct.id);
    final doc2 = _firestore.collection('products').doc(otherProduct.id);

    await _firestore.runTransaction((transaction) async {
      final snap1 = await transaction.get(doc1);
      final snap2 = await transaction.get(doc2);

      if (!snap1.exists || !snap2.exists) return;

      final updatedProduct1 = myProduct.copyWith(ownerId: otherProduct.ownerId);
      final updatedProduct2 = otherProduct.copyWith(ownerId: myProduct.ownerId);

      transaction.update(doc1, updatedProduct1.toJson());
      transaction.update(doc2, updatedProduct2.toJson());
    });
  }

  /// Gets the current user's products from the local list.
  List<Product> getMyProducts({String? category}) {
    return _products.where((product) => product.ownerId == currentUserId && (category == null || product.category == category)).toList();
  }

  /// Stream for marketplace products from Firestore (available and not owned by current user).
  Stream<List<Product>> getMarketplaceProductsStream({String? category}) {
    Query query = _firestore
        .collection('products')
        .where('status', isEqualTo: 'available');

    if (currentUserId != null) {
      query = query.where('ownerId', isNotEqualTo: currentUserId);
    }

    return query.snapshots().map((snapshot) {
      final products = snapshot.docs
          .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      if (category != null) {
        return products.where((product) => product.category == category).toList();
      }
      return products;
    });
  }
}
