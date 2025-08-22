import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class ItemProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Item> _items = [];
  final String userId;

  ItemProvider({required this.userId}) {
    _loadItems();
  }

  List<Item> get items => List.unmodifiable(_items);

  Future<void> addItem(Item item) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('items')
        .doc(item.id)
        .set(item.toMap());
  }

  Future<void> removeItem(String id) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('items')
        .doc(id)
        .delete();
  }

  Future<void> updateItem(Item updatedItem) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('items')
        .doc(updatedItem.id)
        .update(updatedItem.toMap());
  }

  void _loadItems() {
    _firestore
        .collection('users')
        .doc(userId)
        .collection('items')
        .snapshots()
        .listen((snapshot) async {
      _items = snapshot.docs
          .map((doc) => Item.fromMap(doc.data()))
          .toList();

      // إذا القائمة فاضية، نضيف عنصر افتراضي
      if (_items.isEmpty) {
        final defaultItem = Item(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'عنصر تجريبي',
          description: 'هذا عنصر مضاف تلقائيًا للتجربة',
        );
        await addItem(defaultItem);
      }

      notifyListeners();
    });
  }
}
