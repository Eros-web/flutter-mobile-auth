import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:myapp/provider/cart_provider.dart';
import 'package:myapp/provider/location_provider.dart';
import 'package:myapp/provider/voucher_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:myapp/page/promo_page.dart';
import 'package:myapp/component/order_model.dart';
import 'package:myapp/page/history_page.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic>? selectedVoucher;

  const CheckoutPage({super.key, this.selectedVoucher});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final addressController = TextEditingController();
  String selectedPayment = 'Transfer Bank';

  final double deliveryFee = 10000;
  final double serviceFee = 2000;
  final double appFee = 1500;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = context.read<CartProvider>();
      final voucherProvider = context.read<VoucherProvider>();

      final originalTotal = cart.items.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );

      voucherProvider.applyAutoPromos(originalTotal);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final location = context.watch<LocationProvider>();
    final voucherProvider = context.watch<VoucherProvider>();
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final selectedVoucher = widget.selectedVoucher;
    final selectedCode = selectedVoucher?['code'] ?? voucherProvider.selectedCode;

    final originalTotal = cart.items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    final isDelivery = location.method == 'Delivery';

    bool hasFreeDelivery = false;
    if (selectedVoucher != null && selectedVoucher['type'] == 'free_shipping') {
      hasFreeDelivery = true;
    }
    for (var promo in voucherProvider.availablePromos) {
      if (promo['type'] == 'free_shipping' &&
          promo['autoApply'] == true &&
          originalTotal >= (promo['minOrder'] ?? 0)) {
        hasFreeDelivery = true;
        break;
      }
    }

    final double appliedDeliveryFee = isDelivery
        ? (hasFreeDelivery ? 0 : deliveryFee)
        : serviceFee;

    final autoDiscount = voucherProvider.autoDiscount;

    double manualDiscount = 0.0;
    if (selectedVoucher != null) {
      final type = selectedVoucher['type'];
      final value = selectedVoucher['value'];
      if (type == 'percent') {
        manualDiscount = (originalTotal * (value / 100)).clamp(0, originalTotal);
      } else if (type == 'amount') {
        manualDiscount = (value as num).toDouble().clamp(0, originalTotal);
      }
    } else {
      manualDiscount = voucherProvider.discount;
    }

    final totalDiscount = autoDiscount + manualDiscount;
    final discountedTotal = (originalTotal - totalDiscount).clamp(0, double.infinity) + appliedDeliveryFee + appFee;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detail Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Card(
              child: ListTile(
                title: const Text('Outlet'),
                subtitle: Text(location.outlet ?? 'Belum ada outlet terpilih.'),
                trailing: TextButton(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(context, '/search_location') as Map<String, dynamic>?;
                    if (result != null) {
                      Provider.of<LocationProvider>(context, listen: false).updateSafe(
                        result['location'],
                        result['method'],
                        outlet: result['outlet'],
                      );
                      setState(() {});
                    }
                  },
                  child: const Text('Pilih Outlet'),
                ),
              ),
            ),

            const SizedBox(height: 10),

            if (isDelivery) ...[
              Row(
                children: [
                  const Text("Alamat Tujuan:", style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, '/search_location') as Map<String, dynamic>?;
                      if (result != null && result['address'] != null) {
                        Provider.of<LocationProvider>(context, listen: false).addAddress(result['address']);
                        addressController.text = result['address'];
                        setState(() {});
                      }
                    },
                    child: const Text("Pilih"),
                  ),
                ],
              ),
              if (location.addresses.isEmpty)
                const Text("Belum ada alamat tujuan."),
              if (location.addresses.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: location.addresses.length,
                  itemBuilder: (context, index) {
                    final address = location.addresses[index];
                    return ListTile(
                      title: Text(address),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          Provider.of<LocationProvider>(context, listen: false).removeAddress(index);
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
            ],

            ListTile(
              title: const Text("Gunakan Voucher Promo"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final selected = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PromoPage()),
                );

                if (selected != null && selected is Map<String, dynamic>) {
                  voucherProvider.applyVoucher(selected['code'], originalTotal);
                  setState(() {});
                }
              },
            ),
            if (selectedCode != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kode Promo:', style: TextStyle(color: Colors.blue)),
                    Text(selectedCode, style: const TextStyle(color: Colors.blue)),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedPayment,
              items: ['Transfer Bank', 'QRIS', 'COD']
                  .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                  .toList(),
              onChanged: (value) => setState(() => selectedPayment = value!),
              decoration: const InputDecoration(
                labelText: 'Metode Pembayaran',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return ListTile(
                  title: Text('${item.name} × ${item.quantity}'),
                  trailing: Text(formatCurrency.format(item.price * item.quantity)),
                );
              },
            ),

            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total Asli:'), Text(formatCurrency.format(originalTotal)),
            ]),
            if (manualDiscount > 0)
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Diskon Voucher:', style: TextStyle(color: Colors.green)),
                Text('- ${formatCurrency.format(manualDiscount)}', style: const TextStyle(color: Colors.green)),
              ]),
            if (autoDiscount > 0)
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Diskon Otomatis:', style: TextStyle(color: Colors.teal)),
                Text('- ${formatCurrency.format(autoDiscount)}', style: const TextStyle(color: Colors.teal)),
              ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(isDelivery ? 'Ongkos Kirim:' : 'Biaya Layanan:'),
              Text(
                hasFreeDelivery
                    ? 'Gratis'
                    : formatCurrency.format(appliedDeliveryFee),
                style: TextStyle(color: hasFreeDelivery ? Colors.green : null),
              ),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Biaya Aplikasi:'), Text(formatCurrency.format(appFee)),
            ]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
              Text('Total Bayar:', style: TextStyle(fontWeight: FontWeight.bold)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(formatCurrency.format(discountedTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                debugPrint('🔥 Tombol Bayar Sekarang ditekan!');
                  final hasAddress = location.addresses.isNotEmpty;
                  final hasOutlet = location.outlet != null;
                  final isDelivery = location.method.toLowerCase() == 'delivery';

                  if ((isDelivery && !hasAddress) || !hasOutlet) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mohon pilih outlet dan alamat tujuan terlebih dahulu')),
                    );
                    return;
                  }

                  if (cart.items.any((item) => item.quantity <= 0)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ada item dengan jumlah 0')),
                    );
                    return;
                  }

                  final paymentStatus = selectedPayment == 'QRIS' ? 'Paid' : 'Unpaid';
                  final uid = FirebaseAuth.instance.currentUser?.uid;

                  if (uid == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pengguna tidak terautentikasi!')),
                    );
                    return;
                  }

                  final order = OrderModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    items: List.from(cart.items),
                    totalPrice: discountedTotal,
                    orderDate: DateTime.now(),
                    paymentMethod: selectedPayment,
                    paymentStatus: paymentStatus,
                    status: 'Diproses',
                    userId: uid, // ✅ Tambahkan ini
                    address: isDelivery ? location.addresses.first : null, // ✅ Kalau Delivery
                    outlet: location.outlet, // ✅ Outlet untuk Pickup/Dine In
                  );

                  try {
                    debugPrint('🚀 Simpan order ke Firestore...');
                    await FirebaseFirestore.instance.collection('orders').add({
                      'id': order.id,
                      'userId': uid,
                      'items': order.items.map((e) => {
                        'name': e.name,
                        'price': e.price,
                        'promoPrice': e.promoPrice,
                        'imageUrl': e.imageUrl,
                        'variation': e.variation,
                        'quantity': e.quantity,
                      }).toList(),
                      'totalPrice': order.totalPrice,
                      'orderDate': Timestamp.fromDate(order.orderDate),
                      'paymentMethod': order.paymentMethod,
                      'paymentStatus': order.paymentStatus.toLowerCase(),
                      'status': order.status.toLowerCase(),
                    });

                    debugPrint('✅ Order berhasil dikirim ke Firestore');

                    cart.clearCart();

                    if (!mounted) return;

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryPage()),
                    );
                  } catch (e) {
                    debugPrint('🔥 Error Firestore: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan order: $e')),
                    );
                  }
                },

              child: const Text('Bayar Sekarang'),
            ),

          ],
        ),
      ),
    );
  }
}
