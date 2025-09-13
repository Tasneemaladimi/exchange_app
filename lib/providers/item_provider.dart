import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';
import '../db/database_helper.dart';

class ItemProvider extends ChangeNotifier {
  final String? currentUserId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _itemsSubscription;

  List<Item> _items;
  List<Item> get items => _items;

  ItemProvider({this.currentUserId, List<Item> items = const []}) : _items = items {
    if (currentUserId != null) {
      print("✅ ItemProvider created for user: $currentUserId");
    } else {
      print("✅ ItemProvider created for logged-out user.");
    }
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    super.dispose();
  }

  /// Sets up a real-time stream from Firestore to fetch and sync items.
  void fetchAndSetItems() {
    if (currentUserId == null) {
      _items = [];
      notifyListeners();
      return;
    }

    _itemsSubscription?.cancel();
    _itemsSubscription = _firestore
        .collection('items')
        .where('ownerId', isEqualTo: currentUserId)
        .snapshots()
        .listen((snapshot) async {
      final firestoreItems = snapshot.docs.map((doc) => Item.fromJson(doc.data())).toList();
      _items = firestoreItems;
      notifyListeners();

      // Update local cache
      await DBHelper.clearItems();
      for (var item in _items) {
        await DBHelper.insertItem(item);
      }
      print("🔄 Local cache synced with Firestore.");
    }, onError: (error) {
      print("Error fetching items: $error");
      // Optionally handle error state
    });
  }

  /// Adds a new item to Firestore. The stream will update the local state.
  Future<void> addItem(Item item) async {
    await _firestore.collection('items').doc(item.id).set(item.toJson());
  }

  /// Updates an item in Firestore. The stream will update the local state.
  Future<void> updateItem(Item item) async {
    await _firestore.collection('items').doc(item.id).update(item.toJson());
  }

  /// Removes an item from Firestore. The stream will update the local state.
  Future<void> removeItem(String id) async {
    await _firestore.collection('items').doc(id).delete();
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
