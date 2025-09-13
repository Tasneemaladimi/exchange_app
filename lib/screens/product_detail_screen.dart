import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({required this.product, super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _imageUrlController;
  late String _category;

  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _titleController = TextEditingController(text: _product.title);
    _descController = TextEditingController(text: _product.description);
    _imageUrlController = TextEditingController(text: _product.imageUrl ?? '');
    _category = _product.category;
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final updatedProduct = _product.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      category: _category,
    );

    final provider = Provider.of<ProductProvider>(context, listen: false);
    await provider.updateProduct(updatedProduct);

    setState(() {
      _isEditing = false;
      _isSaving = false;
      _product = updatedProduct;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Product updated")));
  }

  Future<void> _deleteProduct() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    await provider.removeProduct(_product.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: const Color(0xFF4E6CFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: !_isEditing ? _buildDetailView() : _buildEditForm(),
      ),
    );
  }

  Widget _buildDetailView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_product.imageUrl != null)
          Center(child: Image.network(_product.imageUrl!, height: 180, fit: BoxFit.cover)),
        const SizedBox(height: 16),
        Text(_product.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(_product.description, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text("Category: ${_product.category}", style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Text("Status: ${_product.status}", style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text("Edit"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4E6CFF)),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _deleteProduct,
              child: const Text("Delete"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
          const SizedBox(height: 12),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: "Description")),
          const SizedBox(height: 12),
          TextField(controller: _imageUrlController, decoration: const InputDecoration(labelText: "Image URL (optional)")),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            items: const [
              DropdownMenuItem(value: "book", child: Text("Book")),
              DropdownMenuItem(value: "stationery", child: Text("Stationery")),
            ],
            onChanged: (val) => setState(() => _category = val!),
            decoration: const InputDecoration(labelText: "Category"),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => setState(() => _isEditing = false), child: const Text("Cancel")),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Save"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4E6CFF)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
