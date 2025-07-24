import 'package:flutter/material.dart';
import 'package:myapp/detailed/promo_detail_page.dart';
import 'main_screen.dart';
import 'package:provider/provider.dart';
import 'package:myapp/provider/voucher_provider.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  bool _initialized = false;

  final List<Map<String, dynamic>> promos = const [
    {
      'title': 'Voucher Diskon 20%',
      'subtitle': 'Diskon 20% untuk Semua Menu',
      'validity': 'Berlaku sampai 30 Juni 2025',
      'image': 'https://via.placeholder.com/300x150.png?text=Promo+1',
      'type': 'percent',
      'value': 20,
      'minOrder': 25000,
      'autoApply': true,
    },
    {
      'title': 'Gratis Ongkir',
      'subtitle': 'Minimal belanja Rp30.000',
      'validity': 'Otomatis diterapkan saat checkout',
      'image': 'https://via.placeholder.com/300x150.png?text=Gratis+Ongkir',
      'type': 'free_shipping',
      'minOrder': 30000,
      'autoApply': true,
    },
    {
      'code': 'REFNASGOR',
      'title': 'Paket Hemat Nasi Goreng + Es Teh%',
      'subtitle': 'Untuk customer yang order Nasi Goreng',
      'validity': 'Berlaku sepanjang bulan Agustus',
      'image': 'https://via.placeholder.com/300x150.png?text=Promo+3',
      'type': 'amount',
      'value': 15000,
      'conditions': {
        'menuKeyword': 'Nasi Goreng',
      }
    },
    {
      'code': 'HEMAT45',
      'title': 'Voucher Hemat 45%',
      'subtitle': 'Berlaku Sampai Jam 9 Malam',
      'validity': 'Pilihlah Menu Minimal Rp50.000',
      'image': 'https://via.placeholder.com/300x150.png?text=Promo+4',
      'type': 'percent',
      'value': 45,
      'conditions': {
        'minOrder': 50000,
        'maxHour': 21,
      }
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;

      Future.microtask(() {
        final voucherProvider = Provider.of<VoucherProvider>(context, listen: false);
        final voucherPromos = promos.where((p) => p.containsKey('code')).toList();
        voucherProvider.setPromos(voucherPromos);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promo')),
      body: ListView.builder(
        itemCount: promos.length,
        itemBuilder: (context, index) {
          final promo = promos[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PromoDetailPage(promo: promo),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(10),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (promo['image'] != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        promo['image']!,
                        fit: BoxFit.cover,
                        height: 150,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            height: 150,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.broken_image, size: 40)),
                          );
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promo['title'] ?? '',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (promo['subtitle'] != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            promo['subtitle']!,
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                        if (promo['validity'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            promo['validity']!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                        if (promo['autoApply'] == true) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                              const SizedBox(width: 6),
                              Text(
                                'Promo otomatis aktif saat checkout',
                                style: TextStyle(fontSize: 13, color: Colors.blue[700]),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        },
        label: const Text('Lanjut ke Beranda'),
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
