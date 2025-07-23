import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../component/order_model.dart';
import '../component/food_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  String _selectedFilter = 'semua';

  List<OrderModel> _applyFilter(List<OrderModel> orders) {
    if (_selectedFilter == 'semua') return orders;
    return orders.where((order) => order.status == _selectedFilter).toList();
  }

  IconData _getStatusIcon(String paymentStatus) {
    switch (paymentStatus) {
      case 'paid':
        return Icons.verified;
      case 'pending':
        return Icons.timelapse;
      case 'failed':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String paymentStatus) {
    switch (paymentStatus) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getOrderStatusIcon(String status) {
    switch (status) {
      case 'selesai':
        return Icons.check_circle;
      case 'diproses':
        return Icons.sync;
      case 'dibatalkan':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'selesai':
        return Colors.green;
      case 'diproses':
        return Colors.orange;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text('Anda belum login.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(
                labelText: 'Filter Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'semua', child: Text('Semua')),
                DropdownMenuItem(value: 'selesai', child: Text('Selesai')),
                DropdownMenuItem(value: 'diproses', child: Text('Diproses')),
                DropdownMenuItem(value: 'dibatalkan', child: Text('Dibatalkan')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFilter = value;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: uid)
                  .orderBy('orderDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada riwayat pesanan.'));
                }

                final orders = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  DateTime orderDate;

                  try {
                    if (data['orderDate'] is Timestamp) {
                      orderDate = (data['orderDate'] as Timestamp).toDate();
                    } else if (data['orderDate'] is String) {
                      orderDate = DateTime.parse(data['orderDate']);
                    } else {
                      orderDate = DateTime.fromMillisecondsSinceEpoch(0);
                    }
                  } catch (_) {
                    orderDate = DateTime.fromMillisecondsSinceEpoch(0);
                  }

                  final items = (data['items'] as List<dynamic>? ?? []).map((item) {
                    return FoodItem(
                      name: item['name'] ?? '',
                      price: (item['price'] as num?)?.toDouble() ?? 0,
                      promoPrice: item['promoPrice'] != null
                          ? (item['promoPrice'] as num?)?.toDouble()
                          : null,
                      imageUrl: item['imageUrl'] ?? '',
                      variation: item['variation'] ?? '',
                      quantity: (item['quantity'] ?? 1) as int,
                    );
                  }).toList();

                  return OrderModel(
                    id: data['id'] ?? doc.id,
                    userId: data['userId'] ?? '',
                    items: items,
                    totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0,
                    orderDate: orderDate,
                    paymentMethod: data['paymentMethod'] ?? '-',
                    paymentStatus: (data['paymentStatus']?.toString().toLowerCase()) ?? 'unknown',
                    status: (data['status']?.toString().toLowerCase()) ?? 'unknown',
                    address: data['address'],
                    outlet: data['outlet'],
                  );
                }).toList();

                final filtered = _applyFilter(orders);

                if (filtered.isEmpty) {
                  return const Center(child: Text('Tidak ada pesanan untuk filter ini.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    final formatDate = DateFormat('dd-MM-yyyy HH:mm');

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          'Pesanan #${order.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total: ${formatCurrency.format(order.totalPrice)}'),
                            Text('Metode: ${order.paymentMethod}'),
                            Text('Pembayaran: ${order.paymentStatus}'),
                            Text('Status: ${order.status}'),
                            Text('Tanggal: ${formatDate.format(order.orderDate)}'),
                            const SizedBox(height: 6),
                            const Text('Daftar Menu:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ...order.items.map((item) => Text('- ${item.name} x${item.quantity}')),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_getStatusIcon(order.paymentStatus), color: _getStatusColor(order.paymentStatus)),
                            const SizedBox(height: 4),
                            Icon(_getOrderStatusIcon(order.status), color: _getOrderStatusColor(order.status)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
