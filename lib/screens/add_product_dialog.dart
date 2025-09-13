import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'package:uuid/uuid.dart';

class AddProductDialog extends StatefulWidget {
  final String currentUserId;
  const AddProductDialog({super.key, required this.currentUserId});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _category = "book";
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Product"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (val) => val!.isEmpty ? "Enter title" : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (val) => val!.isEmpty ? "Enter description" : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: "Image URL (optional)"),
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(value: "book", child: Text("Book")),
                  DropdownMenuItem(value: "stationery", child: Text("Stationery")),
                ],
                onChanged: (val) => setState(() => _category = val!),
                decoration: const InputDecoration(labelText: "Category"),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isSaving ? null : () async {
            if (!_formKey.currentState!.validate()) return;
            setState(() => _isSaving = true);

            final newProduct = Product(
              id: const Uuid().v4(),
              ownerId: widget.currentUserId,
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
              category: _category,
            );

            final provider = Provider.of<ProductProvider>(context, listen: false);
            await provider.addProduct(newProduct);

            setState(() => _isSaving = false);
            Navigator.pop(context);
          },
          child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Add"),
        ),
      ],
    );
  }
}
