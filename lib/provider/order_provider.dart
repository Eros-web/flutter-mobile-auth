import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../component/order_model.dart';

class OrderProvider with ChangeNotifier {
  // ✅ List internal penyimpanan pesanan
  final List<OrderModel> _orders = [];

  // ✅ Getter: hanya bisa dibaca
  List<OrderModel> get orders => List.unmodifiable(_orders);

  /// ✅ Tambah order secara lokal — opsional, biasanya dipakai setelah save ke Firestore
  void addOrder(OrderModel order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  /// ✅ Hapus semua riwayat pesanan lokal (contoh: logout)
  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  /// ✅ Cari order spesifik berdasarkan ID
  OrderModel? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (_) {
      return null;
    }
  }

  /// ✅ Tarik ulang semua data pesanan dari Firestore → update state lokal
  Future<void> fetchOrders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .get();

      final List<OrderModel> loadedOrders = snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromJson(data);
      }).toList();

      _orders
        ..clear()
        ..addAll(loadedOrders);

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Gagal fetch orders: $e');
      rethrow; // biar bisa di-handle di UI kalau perlu
    }
  }
}
