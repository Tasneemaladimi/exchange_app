import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/exchange_provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  void _showExchangeConfirmationDialog(
      BuildContext context, Product product, ExchangeProvider exchangeProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Exchange'),
        content: Text('Are you sure you want to request an exchange for ${product.title}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Request'),
            onPressed: () async {
              await exchangeProvider.createExchangeRequest(product);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exchange request sent!')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);

    return StreamBuilder<List<Product>>(
      stream: productProvider.getMarketplaceProductsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products available in the marketplace.'));
        }

        final products = snapshot.data!;

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (ctx, i) {
            final product = products[i];
            return ProductCard(
              product: product,
              onTap: () {
                _showExchangeConfirmationDialog(context, product, exchangeProvider);
              },
            );
          },
        );
      },
    );
  }
}
