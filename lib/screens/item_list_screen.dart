import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../models/item.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';
import '../widgets/item_card.dart';
import 'package:uuid/uuid.dart';

class ItemListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemProv = Provider.of<ItemProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('قائمة الأغراض')),
      body: itemProv.items.isEmpty
          ? Center(child: Text('لا توجد أغراض حالياً'))
          : ListView.builder(
              itemCount: itemProv.items.length,
              itemBuilder: (ctx, i) {
                final item = itemProv.items[i];
                return ItemCard(
                  item: item,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ItemDetailScreen(item: item)));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final newItem = await Navigator.push<Item>(
              context, MaterialPageRoute(builder: (_) => AddItemScreen()));
          if (newItem != null) {
            final newItemWithId = Item(
              id: Uuid().v4(),
              title: newItem.title,
              description: newItem.description,
              imageUrl: newItem.imageUrl,
            );
            await itemProv.addItem(newItemWithId);
          }
        },
      ),
    );
  }
}
