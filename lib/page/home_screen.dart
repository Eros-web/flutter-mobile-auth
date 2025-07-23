import 'package:flutter/material.dart';
import 'package:myapp/detailed/product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {
        'title': 'Jus Buah',
        'description': 'Jus Segar dari Beragam Rasa',
        'isPromo': true,
        'image':
            'https://d1vbn70lmn1nqe.cloudfront.net/prod/wp-content/uploads/2022/08/05072542/manfaat-mengonsumsi-jus-mangga-untuk-kesehatan-tubuh-halodoc.jpg',
        'harga': 20000,
        'promoPrice': 15000
      },
      {
        'title': 'Nasi Kucing Sambal Matah',
        'description': 'Nasi Kucing ditambah Ayam, Salad, dan Sambal Matah',
        'isPromo': true,
        'image':
            'https://www.finnafood.com/blog/wp-content/uploads/2024/03/nasi-kucing.jpg',
        'harga': 20000,
        'promoPrice': 15000
      },
      {
        'title': 'Sushi Mentai',
        'description': 'Asli Ikan Salmon',
        'isPromo': true,
        'image':
            'https://ichibansushi.co.id/wp-content/uploads/2024/05/SALMON-MENTAI-NIGIRI.jpg',
        'harga': 20000,
        'promoPrice': 15000
      },
      {
        'title': 'Martabak Manis',
        'description': 'Martabak dengan Beragam Rasa',
        'isPromo': true,
        'image':
            'https://www.dapurkobe.co.id/wp-content/uploads/martabak-manis.jpg',
        'harga': 20000,
        'promoPrice': 15000
      },
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 252, 252),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Metode Pemesanan:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOrderOption(context, Icons.delivery_dining, 'Delivery'),
                  _buildOrderOption(context, Icons.storefront, 'Pickup'),
                  _buildOrderOption(context, Icons.restaurant, 'Dine In'),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Selamat datang di Aplikasi E-Commerce!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Promo Hari Ini',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Divider(thickness: 1.5),
              const SizedBox(height: 10),

              ...products.map((product) {
                final isPromo = product['isPromo'] == true;
                final promoPrice = product['promoPrice'] ?? product['harga'];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          title: product['title'],
                          description: product['description'],
                          image: product['image'],
                          harga: (promoPrice as int).toDouble(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: Image.network(
                            product['image'],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(
                                width: 120,
                                height: 120,
                                child: Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[300],
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image,
                                    color: Colors.grey, size: 40),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product['title'],
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    if (isPromo)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'PROMO',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  product['description'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                isPromo
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Rp ${product['promoPrice']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            'Rp ${product['harga']}',
                                            style: const TextStyle(
                                              decoration: TextDecoration.lineThrough,
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Rp ${product['harga']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 14,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderOption(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/checkout',
          arguments: {
            'method': label,
            'selectedOutlet': label == 'Pickup' ? 'Outlet A' : null,
          },
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurple.shade100,
            child: Icon(icon, color: Colors.deepPurple),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
