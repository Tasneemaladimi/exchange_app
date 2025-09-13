import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'add_product_dialog.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatelessWidget {
  final String category;
  const ProductListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final productProv = Provider.of<ProductProvider>(context);
    final myProducts = productProv.getMyProducts();

    final filteredProducts = myProducts.where((product) => product.category == category).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category == "book" ? "Books" : "Stationery"),
        backgroundColor: const Color(0xFF4E6CFF),
      ),
      body: filteredProducts.isEmpty
          ? const Center(child: Text("No products available"))
          : ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ListTile(
                  leading: product.imageUrl != null
                      ? Image.network(product.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.book),
                  title: Text(product.title),
                  subtitle: Text(product.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          final userId = productProv.currentUserId;
          if (userId != null) {
            showDialog(
              context: context,
              builder: (ctx) => AddProductDialog(currentUserId: userId),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("You must be logged in to add products.")),
            );
          }
        },
        child: const Icon(Icons.add, size: 30),
      ),

    );
  }
}
