import 'package:flutter/material.dart';
import 'package:myapp/page/checkout_page.dart'; // Pastikan path-nya benar

class PromoDetailPage extends StatefulWidget {
  final Map<String, dynamic> promo;

  const PromoDetailPage({super.key, required this.promo});

  @override
  State<PromoDetailPage> createState() => _PromoDetailPageState();
}

class _PromoDetailPageState extends State<PromoDetailPage> {
  final TextEditingController referralController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final promo = widget.promo;

    // Hanya tampilkan input referral jika kodenya termasuk yang manual
    final hasManualCode = ['REFNASGOR', 'HEMAT45']
        .contains(promo['code']?.toString().toUpperCase());

    return Scaffold(
      appBar: AppBar(title: Text(promo['title'] ?? 'Detail Promo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (promo['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  promo['image']!,
                  fit: BoxFit.cover,
                  height: 160,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 160,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 40),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            Text(
              promo['title'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (promo['subtitle'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(promo['subtitle']!, style: const TextStyle(fontSize: 16)),
              ),
            if (promo['validity'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Masa Berlaku: ${promo['validity']}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 20),

            if (hasManualCode) ...[
              const Text('Masukkan Kode Referral:'),
              const SizedBox(height: 8),
              TextField(
                controller: referralController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: REFNASGOR atau HEMAT45',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('Gunakan Voucher'),
                onPressed: () {
                  if (hasManualCode) {
                    final inputCode = referralController.text.trim().toUpperCase();
                    final correctCode = promo['code']?.toString().toUpperCase();

                    if (inputCode != correctCode) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kode referral tidak valid')),
                      );
                      return;
                    }
                  }

                  // Langsung arahkan ke CheckoutPage dengan promo terpasang
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutPage(selectedVoucher: promo),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
