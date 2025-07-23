import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/provider/cart_provider.dart';
import 'package:myapp/component/food_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final String title;
  final String description;
  final String image;
  final double harga;
  final double? promoPrice; // ✅ Tambahkan promoPrice

  const ProductDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.harga,
    this.promoPrice, // ✅ Konstruktor menerima promoPrice
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<String> _variasi = [];
  String? _variasiTerpilih;

  final double _rating = 4.5;
  final List<String> _ulasan = [
    'Produk enak banget!',
    'Pelayanan cepat dan ramah.',
    'Rasanya mantap, akan beli lagi.',
  ];

  @override
  void initState() {
    super.initState();

    _variasi = _getVariasiForProduct(widget.title);
    if (_variasi.isNotEmpty) {
      _variasiTerpilih = _variasi.first;
    }
  }

  List<String> _getVariasiForProduct(String title) {
    switch (title) {
      case 'Jus Buah':
        return ['Mangga', 'Apel', 'Jeruk', 'Alpukat', 'Buah Naga', 'Semangka'];
      case 'Martabak Manis':
        return ['Coklat', 'Keju', 'GreenTea'];
      case 'Bakso Ayam':
        return ['Small', 'Besar', 'Jumbo'];
      case 'Milkshake':
        return ['Vanilla', 'Coklat', 'Strawberry', 'Pisang', 'Oreo', 'Taro', 'Cotton Candy', 'Red Velvet'];
      case 'Kopi':
        return ['Macchiato', 'Espresso', 'Cappuccino', 'Latte', 'Americano', 'Mocha'];
      case 'Nasi Ayam Geprek':
        return ['Original', 'Mozarella', 'Sambal Matah', 'Sambal Hijau', 'BBQ', 'Saus Bangkok'];
      case 'Ikan Goreng Saus':
        return ['Asam Manis', 'Saus Bangkok', 'Tiram', 'Cabe Merah'];
      case 'Sandwich':
        return ['Chicken Katsu', 'Tuna', 'Salmon','Cokelat', 'Srikaya'];
      case 'Pizza':
        return ['Mozarella', 'Peperoni', 'Mushroms'];
      case 'Kue Tradisional':
        return ['Kue Lupis', 'Klepon', 'Pastel', 'Kue Lapis', 'Nagasari'];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectivePrice = widget.promoPrice ?? widget.harga;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 60),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            // Harga dan promo
            widget.promoPrice != null
              ? Row(
                  children: [
                    Text(
                      'Rp ${widget.harga.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rp ${widget.promoPrice!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Rp ${widget.harga.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            const SizedBox(height: 16),

            // Dropdown variasi
            if (_variasi.isNotEmpty)
              Row(
                children: [
                  const Text("Pilih Variasi:", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _variasiTerpilih,
                    onChanged: (newValue) => setState(() => _variasiTerpilih = newValue),
                    items: _variasi.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  ),
                ],
              ),
            if (_variasi.isNotEmpty) const SizedBox(height: 16),

            Row(
              children: [
                const Text("Rating:", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                ...List.generate(5, (index) {
                  return Icon(
                    index < _rating.round() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text("$_rating / 5", style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),

            const Text("Ulasan Pelanggan:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._ulasan.map((u) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text("• $u"),
            )),
            const SizedBox(height: 24),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final cart = Provider.of<CartProvider>(context, listen: false);
                    cart.addToCart(FoodItem(
                      name: widget.title,
                      price: effectivePrice,
                      promoPrice: widget.promoPrice?.toDouble(), 
                      imageUrl: widget.image,
                      variation: _variasiTerpilih,
                      quantity: 1,
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produk berhasil ditambahkan ke keranjang!')),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text("Tambahkan ke Keranjang"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.orange,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    final cart = Provider.of<CartProvider>(context, listen: false);
                    cart.clearCart();
                    cart.addToCart(FoodItem(
                      name: widget.title,
                      price: effectivePrice,
                      imageUrl: widget.image,
                      variation: _variasiTerpilih,
                      quantity: 1,
                    ));
                    Navigator.pushNamed(context, '/checkout');
                  },
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text("Beli Sekarang"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
