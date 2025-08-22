import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemDetailScreen extends StatelessWidget {
  final Item item;
  const ItemDetailScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            item.imageUrl != null
                ? Image.network(item.imageUrl!)
                : Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: Center(child: Text('لا توجد صورة')),
                  ),
            SizedBox(height: 16),
            Text(
              item.description,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
