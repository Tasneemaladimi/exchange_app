import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final Color? borderColor;

  const ItemCard({
    required this.item,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.borderColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderColor != null
            ? BorderSide(color: borderColor!, width: 2)
            : BorderSide.none,
      ),
      elevation: 3,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: item.imageUrl != null && item.imageUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                item.category == "book" ? Icons.book : Icons.create,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
        title: Text(item.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: item.description.isNotEmpty
            ? Text(item.description,
                maxLines: 2, overflow: TextOverflow.ellipsis)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit),
            if (onDelete != null)
              IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
