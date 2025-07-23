import 'food_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final List<FoodItem> items;
  final double totalPrice;
  final DateTime orderDate;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String userId; // ✅ tambahan penting kalau kamu pakai uid
  final String? address; // ✅ kalau delivery
  final String? outlet;  // ✅ kalau pickup/dine in

  OrderModel({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.orderDate,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.userId,
    this.address,
    this.outlet,
  });

  /// ✅ Konversi dari JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => FoodItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      orderDate: json['orderDate'] is Timestamp
          ? (json['orderDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['orderDate'].toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
      paymentMethod: json['paymentMethod'] ?? '-',
      paymentStatus: (json['paymentStatus'] ?? 'unknown').toString().toLowerCase(),
      status: (json['status'] ?? 'unknown').toString().toLowerCase(),
      address: json['address'],
      outlet: json['outlet'],
    );
  }

  /// ✅ Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'orderDate': orderDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus.toLowerCase(),
      'status': status.toLowerCase(),
      'address': address,
      'outlet': outlet,
    };
  }
}
