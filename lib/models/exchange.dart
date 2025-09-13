import 'package:cloud_firestore/cloud_firestore.dart';

class Exchange {
  final String exchangeId;
  final String productId;
  final String productTitle;
  final String ownerId;
  final String requesterId;
  final String status; // "pending", "accepted", "rejected"
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Exchange({
    required this.exchangeId,
    required this.productId,
    required this.productTitle,
    required this.ownerId,
    required this.requesterId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Exchange.fromJson(Map<String, dynamic> json) {
    return Exchange(
      exchangeId: json['exchangeId'],
      productId: json['productId'],
      productTitle: json['productTitle'],
      ownerId: json['ownerId'],
      requesterId: json['requesterId'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exchangeId': exchangeId,
      'productId': productId,
      'productTitle': productTitle,
      'ownerId': ownerId,
      'requesterId': requesterId,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
