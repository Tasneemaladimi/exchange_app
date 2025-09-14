import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class ExchangeScreen extends StatefulWidget {
  final String currentUserId;

  const ExchangeScreen({super.key, required this.currentUserId});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  Product? mySelectedProduct;
  Product? otherSelectedProduct;

  @override
  Widget build(BuildContext context) {
    final productProv = Provider.of<ProductProvider>(context);

    final myProducts = productProv.getMyProducts();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exchange Products"),
        backgroundColor: const Color(0xFF4E6CFF),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<Product>(
              hint: const Text("Select your product"),
              value: mySelectedProduct,
              isExpanded: true,
              items: myProducts.map((product) {
                return DropdownMenuItem(
                  value: product,
                  child: Text(product.title),
                );
              }).toList(),
              onChanged: (product) {
                setState(() {
                  mySelectedProduct = product;
                });
              },
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<Product>>(
              // CORRECTED: Replaced non-existent method with the correct one.
              stream: productProv.getMarketplaceProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("No products available for exchange"));
                }

                final otherProducts = snapshot.data!;

                return ListView.builder(
                  itemCount: otherProducts.length,
                  itemBuilder: (ctx, i) {
                    final product = otherProducts[i];
                    final isSelected = product == otherSelectedProduct;

                    return ListTile(
                      title: Text(product.title),
                      subtitle: Text("Owner: ${product.ownerId}"),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          otherSelectedProduct = product;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: (mySelectedProduct != null &&
                      otherSelectedProduct != null)
                  ? () async {
                      await productProv.exchangeProducts(
                          mySelectedProduct!, otherSelectedProduct!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Products exchanged successfully")),
                      );
                      setState(() {
                        mySelectedProduct = null;
                        otherSelectedProduct = null;
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E6CFF),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
              child: const Text("Exchange", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
