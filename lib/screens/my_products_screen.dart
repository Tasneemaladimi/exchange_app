import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/product_card.dart';
import 'add_product_dialog.dart';
import 'product_detail_screen.dart';

class MyProductsScreen extends StatelessWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myProducts = productProvider.products;

    return Scaffold(
      body: myProducts.isEmpty
          ? const Center(child: Text("You haven't added any products yet."))
          : ListView.builder(
              itemCount: myProducts.length,
              itemBuilder: (ctx, i) {
                final product = myProducts[i];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  onDelete: () async {
                    await productProvider.removeProduct(product.id);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // CORRECTED: Changed authProvider.currentUser?.id to authProvider.user?.id
          final userId = authProvider.user?.uid;
          if (userId != null) {
            showDialog(
              context: context,
              builder: (ctx) => AddProductDialog(currentUserId: userId),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
