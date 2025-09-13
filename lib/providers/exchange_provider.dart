import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/exchange.dart';

class ExchangeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId;

  ExchangeProvider(this._userId);

  /// Creates a new exchange request.
  Future<void> createExchangeRequest(Product product) async {
    if (_userId == null) return;

    final newExchange = Exchange(
      exchangeId: const Uuid().v4(),
      productId: product.id,
      productTitle: product.title,
      ownerId: product.ownerId,
      requesterId: _userId!,
      status: 'pending',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    await _firestore
        .collection('exchanges')
        .doc(newExchange.exchangeId)
        .set(newExchange.toJson());
  }

  /// Gets a stream of incoming exchange requests for the current user.
  Stream<List<Exchange>> getIncomingExchangeRequestsStream() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('exchanges')
        .where('ownerId', isEqualTo: _userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Exchange.fromJson(doc.data())).toList());
  }

  /// Accepts an exchange request.
  Future<void> acceptExchange(String exchangeId) async {
    final exchangeRef = _firestore.collection('exchanges').doc(exchangeId);

    // Temporary Client-Side Finalization
    // In a real app, this should be a Cloud Function for reliability.
    try {
      final exchangeDoc = await exchangeRef.get();
      if (!exchangeDoc.exists) return;

      final productId = exchangeDoc.data()!['productId'];

      // 1. Update the product's status to 'exchanged'
      final productRef = _firestore.collection('products').doc(productId);
      await productRef.update({'status': 'exchanged'});

      // 2. Update the exchange status to 'accepted'
      await exchangeRef.update({'status': 'accepted', 'updatedAt': Timestamp.now()});

      print('Exchange finalized on the client-side.');
    } catch (e) {
      print('Error during client-side finalization: $e');
      // Optionally, handle the error (e.g., show a message to the user)
    }
  }

  /// Rejects an exchange request.
  Future<void> rejectExchange(String exchangeId) async {
    await _firestore
        .collection('exchanges')
        .doc(exchangeId)
        .update({'status': 'rejected', 'updatedAt': Timestamp.now()});
  }
}
