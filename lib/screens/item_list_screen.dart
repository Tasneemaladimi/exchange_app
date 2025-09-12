import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../models/item.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';
import '../widgets/item_card.dart';
import 'package:uuid/uuid.dart';

class ItemListScreen extends StatelessWidget {
  final String category;
  const ItemListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final itemProv = Provider.of<ItemProvider>(context);
    final myItems = itemProv.getMyItems(); // جلب عناصر المستخدم الحالي

    // تصفية العناصر حسب الفئة
    final filteredItems = myItems.where((item) => item.category == category).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category == "book" ? "Books" : "Stationery"),
        backgroundColor: const Color(0xFF4E6CFF),
      ),
      body: filteredItems.isEmpty
          ? const Center(child: Text("No items available"))
          : ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return ListTile(
                  leading: item.imageUrl != null
                      ? Image.network(item.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.book),
                  title: Text(item.title),
                  subtitle: Text(item.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetailScreen(item: item),
                      ),
                    );
                  },
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
  backgroundColor: Theme.of(context).primaryColor,
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddItemScreen(currentUserId: currentUserId), // ⚡ تمرير معرف المستخدم
      ),
    );
  },
  child: const Icon(Icons.add, size: 30),
),

    );
  }
}
