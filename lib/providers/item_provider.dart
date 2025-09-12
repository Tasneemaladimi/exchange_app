import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';
import '../db/database_helper.dart';

class ItemProvider extends ChangeNotifier {
  final String currentUserId; // معرف المستخدم الحالي
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Item> _items = [];
  List<Item> get items => _items;

  ItemProvider({required this.currentUserId}) {
      print("✅ ItemProvider created for user: $currentUserId");
    loadLocalItems();
  }

  /// تحميل العناصر المحفوظة محليًا
  Future<void> loadLocalItems() async {
    _items = await DBHelper.getItems();
    notifyListeners();
  }

  /// إضافة عنصر جديد (محلي + Firestore)
  Future<void> addItem(Item item, {bool saveToFirestore = false}) async {
    // حفظ محلي
    await DBHelper.insertItem(item);
    _items.add(item);
    notifyListeners();

    // حفظ في Firestore إذا مطلوب
    if (saveToFirestore) {
      await _firestore.collection('items').doc(item.id).set(item.toJson());
    }
  }

  /// تحديث عنصر (محلي + Firestore)
  Future<void> updateItem(Item item, {bool updateFirestore = false}) async {
    // تحديث محلي
    await DBHelper.updateItem(item);
    updateLocalItem(item);

    // تحديث Firestore إذا مطلوب
    if (updateFirestore) {
      await _firestore.collection('items').doc(item.id).update(item.toJson());
    }
  }

  /// حذف عنصر (محلي + Firestore)
  Future<void> removeItem(String id, {bool removeFromFirestore = false}) async {
    // حذف محلي
    await DBHelper.deleteItem(id);
    removeLocalItem(id);

    // حذف من Firestore إذا مطلوب
    if (removeFromFirestore) {
      await _firestore.collection('items').doc(id).delete();
    }
  }

  /// تحديث عنصر موجود في قائمة العناصر المحلية فقط
  void updateLocalItem(Item item) {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _items[index] = item;
      notifyListeners();
    }
  }

  /// حذف عنصر محلي فقط
  void removeLocalItem(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// تبادل عنصرين بين مستخدمين عبر Firestore
  Future<void> exchangeItems(Item myItem, Item otherItem) async {
    final doc1 = _firestore.collection('items').doc(myItem.id);
    final doc2 = _firestore.collection('items').doc(otherItem.id);

    await _firestore.runTransaction((transaction) async {
      final snap1 = await transaction.get(doc1);
      final snap2 = await transaction.get(doc2);

      if (!snap1.exists || !snap2.exists) return;

      final updatedItem1 = myItem.copyWith(ownerId: otherItem.ownerId);
      final updatedItem2 = otherItem.copyWith(ownerId: myItem.ownerId);

      transaction.update(doc1, updatedItem1.toJson());
      transaction.update(doc2, updatedItem2.toJson());
    });
  }

  /// استرجاع العناصر الخاصة بالمستخدم من SQLite
  List<Item> getMyItems({String? category}) {
    return _items.where((item) => item.ownerId == currentUserId && (category == null || item.category == category)).toList();
  }

  /// Stream لعناصر الآخرين من Firestore
  Stream<List<Item>> otherUsersItemsStream([String? category]) {
    return _firestore.collection('items').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Item.fromJson(doc.data()))
              .where((item) => item.ownerId != currentUserId && (category == null || item.category == category))
              .toList(),
        );
  }
}
