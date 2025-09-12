import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../db/database_helper.dart';
import '../providers/item_provider.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item; // تعديل: تمرير العنصر بالكامل
  const ItemDetailScreen({required this.item, super.key});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _imageUrlController;
  late String _category;

  late Item _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _titleController = TextEditingController(text: _item.title);
    _descController = TextEditingController(text: _item.description);
    _imageUrlController = TextEditingController(text: _item.imageUrl ?? '');
    _category = _item.category;
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final updatedItem = _item.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      category: _category,
    );

    // حفظ محلي
    await DBHelper.updateItem(updatedItem);
    // تحديث Provider
    final provider = Provider.of<ItemProvider>(context, listen: false);
    provider.updateLocalItem(updatedItem);
    // تحديث Firestore
    provider.updateItem(updatedItem);

    setState(() {
      _isEditing = false;
      _isSaving = false;
      _item = updatedItem;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Item updated")));
  }

  Future<void> _deleteItem() async {
    // حذف محلي
    await DBHelper.deleteItem(_item.id);
    final provider = Provider.of<ItemProvider>(context, listen: false);
    provider.removeLocalItem(_item.id);
    // حذف من Firestore
    provider.removeItem(_item.id);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Details"),
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
        if (_item.imageUrl != null)
          Center(child: Image.network(_item.imageUrl!, height: 180, fit: BoxFit.cover)),
        const SizedBox(height: 16),
        Text(_item.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(_item.description, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text("Category: ${_item.category}", style: const TextStyle(color: Colors.grey)),
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
              onPressed: _deleteItem,
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
