import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/detailed/product_detail_screen.dart';

class CombinedMenuPage extends StatelessWidget {
  const CombinedMenuPage({super.key});

  static final List<Map<String, dynamic>> allProducts = [
    {
      'title': 'Jus Buah',
      'description': 'Jus Segar dari Beragam Rasa',
      'isPromo': true,
      'image':
          'https://d1vbn70lmn1nqe.cloudfront.net/prod/wp-content/uploads/2022/08/05072542/manfaat-mengonsumsi-jus-mangga-untuk-kesehatan-tubuh-halodoc.jpg',
      'harga': 20000,
      'promoPrice': 15000,
      'kategori': 'Minuman',
    },
    {
      'title': 'Milkshake',
      'description': 'Beragam Rasa Milkshake',
      'isPromo': false,
      'image':
          'https://assets.epicurious.com/photos/647df8cad9749492c4d5d407/1:1/w_1920,c_limit/StrawberryMilkshake_RECIPE_053123_3599.jpg',
      'harga': 20000,
      'kategori': 'Minuman',
    },
    {
      'title': 'Kopi',
      'description': 'Beragam Rasa Kopi',
      'isPromo': false,
      'image':
          'https://res.cloudinary.com/dk0z4ums3/image/upload/v1594099343/attached_image/ini-manfaat-konsumsi-kopi-hitam-dan-efek-sampingnya-untuk-kesehatan-0-alodokter.jpg',
      'harga': 20000,
      'kategori': 'Minuman',
    },
    {
      'title': 'Nasi Kucing Sambal Matah',
      'description': 'Nasi Kucing ditambah Ayam, Salad, dan Sambal Matah',
      'isPromo': true,
      'image': 'https://www.finnafood.com/blog/wp-content/uploads/2024/03/nasi-kucing.jpg',
      'harga': 20000,
      'promoPrice': 15000,
      'kategori': 'Makanan Saji',
    },
    {
      'title': 'Mie Goreng Special',
      'description': 'Mie Goreng dengan Telur dan Sayur',
      'isPromo': false,
      'image': 'https://cdn0-production-images-kly.akamaized.net/Z5LOlqFJEHFlzcVNp8OOIjfO1B0=/0x342:5989x3718/680x383/filters:quality(75):strip_icc():format(webp)/kly-media-production/medias/3930827/original/066100900_1644554867-shutterstock_1984582070.jpg',
      'harga': 15000,
      'kategori': 'Makanan Saji',
    },
    {
      'title': 'Sate Ayam',
      'description': 'Sate Ayam dengan Bumbu Kacang',
      'isPromo': false,
      'image': 'https://asset.kompas.com/crops/BJdOTeUCdwHWS6ImI9qDnf3s8nI=/0x0:1000x667/1200x800/data/photo/2023/12/19/6580e31d4d33e.jpeg',
      'harga': 25000,
      'kategori': 'Makanan Saji',
    },
    {
      'title': 'Sushi Mentai',
      'description': 'Asli Ikan Salmon',
      'isPromo': true,
      'image': 'https://ichibansushi.co.id/wp-content/uploads/2024/05/SALMON-MENTAI-NIGIRI.jpg',
      'harga': 20000,
      'promoPrice': 15000,
      'kategori': 'Makanan Jepang',
    },
    {
      'title': 'Martabak Manis',
      'description': 'Martabak dengan Beragam Rasa',
      'isPromo': true,
      'image': 'https://www.dapurkobe.co.id/wp-content/uploads/martabak-manis.jpg',
      'harga': 20000,
      'promoPrice': 15000,
      'kategori': 'Dessert',
    },
    {
      'title': 'Salad Buah',
      'description': 'Buah Segar dengan Yogurt',
      'isPromo': false,
      'image': 'https://akcdn.detik.net.id/visual/2022/06/23/cara-membuat-salad-buah-yang-enak-dan-praktis_169.jpeg?w=750&q=90',
      'harga': 18000,
      'kategori': 'Makanan Sehat',
    },
    {
      'title': 'Nasi Ayam Geprek',
      'description': 'Nasi Ayam Geprek dengan Berbagai Variasi Pedas',
      'isPromo': false,
      'image': 'https://cdn.rri.co.id/berita/Palangkaraya/o/1727243778485-IMG_3660/57xmqb0nyz2u89w.jpeg',
      'harga': 18000,
      'kategori': 'Makanan Saji',
    },
    {
      'title': 'Nasi Ayam Lada',
      'description': 'Disajikan dengan Ayam dengan Bumbu Lada Hitam',
      'isPromo': false,
      'image': 'https://buckets.sasa.co.id/v1/AUTH_Assets/Assets/p/website/medias/page_medias/rice_bowl_ayam_lada_hitam_.jpg',
      'harga': 18000,
      'kategori': 'Makanan Saji',
    },
    {
      'title': 'Cumi Goreng',
      'description': 'Cumi Goreng Tepung',
      'isPromo': false,
      'image': 'https://pict.sindonews.net/dyn/732/pena/news/2021/03/08/185/357390/resep-cumi-goreng-tepung-yang-empuk-krenyes-ghy.jpg',
      'harga': 18000,
      'kategori': 'Makanan Saji',
    },
    {
      'title': 'Ikan Goreng Saus',
      'description': 'Ikan Goreng dengan Variasi Saus',
      'isPromo': false,
      'image': 'https://image.idntimes.com/post/20240206/ikan-thailand-abb7d992a173755856c2abd3ea40e081.jpeg?tr=w-1920,f-webp,q-75&width=1920&format=webp&quality=75',
      'harga': 18000,
      'kategori': 'Makanan Saji',
    },
    {
      'title': 'Nasi Kuning',
      'description': 'Nasi Kuning dengan Beragam Isi',
      'isPromo': true,
      'image': 'https://www.dapurkobe.co.id/wp-content/uploads/nasi-kuning-kobe.jpg',
      'harga': 18000,
      'promoPrice': 15000,
      'kategori': 'Makanan Saji',
    },
    {
      'title': 'Nasi Goreng',
      'description': 'Bisa dipilih variasi nasi goreng',
      'isPromo': true,
      'image': 'https://thestarvingchefblog-com.translate.goog/wp-content/uploads/2024/04/indonesian-nasi-goreng.jpg?_x_tr_sl=en&_x_tr_tl=id&_x_tr_hl=id&_x_tr_pto=imgs',
      'harga': 18000,
      'promoPrice': 15000,
      'kategori': 'Makanan Saji',
    },
    {
      'title': 'Teh Manis',
      'description': 'Pilih ice atau hot',
      'isPromo': false,
      'image': 'https://akcdn.detik.net.id/community/media/visual/2024/03/10/ilustrasi-teh-manis_169.jpeg?w=700&q=90',
      'harga': 18000,
      'kategori': 'Minuman',
    },
    {
      'title': 'Kue Tradisional',
      'description': 'Variasi Kue Tradisional yang dipilih',
      'isPromo': false,
      'image': 'https://cdn0-production-images-kly.akamaized.net/70mG4Bqs9-kby_M7Oki6kir7F4Q=/640x360/smart/filters:quality(75):strip_icc():format(webp)/kly-media-production/medias/3473546/original/097829700_1622812563-1083px-Jajan_Pasar_in_Jakarta.jpg',
      'harga': 18000,
      'kategori': 'Dessert',
    },
    {
      'title': 'Sandwich',
      'description': 'Sandwich dengan berbagai Variasi',
      'isPromo': false,
      'image': 'https://www.watermelon.org/wp-content/uploads/2023/02/Sandwich_2023-1000x1000.jpg',
      'harga': 18000,
      'kategori': 'Dessert',
    },
    {
      'title': 'Pizza',
      'description': 'Pizza dengan Beranekaragam Rasa',
      'isPromo': false,
      'image': 'https://assets.surlatable.com/m/15a89c2d9c6c1345/72_dpi_webp-REC-283110_Pizza.jpg',
      'harga': 18000,
      'kategori': 'Dessert',
    },
    {
      'title': 'Nasi Bento',
      'description': 'Nasi Kotak berisi makanan Bento',
      'isPromo': false,
      'image': 'https://blue.kumparan.com/image/upload/fl_progressive,fl_lossy,c_fill,f_auto,q_auto:best,w_640/v1517916785/toxx6jub8ttsl193g1z8.jpg',
      'harga': 18000,
      'kategori': 'Makanan Jepang',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.black,
            isScrollable: true,
            indicatorColor: Colors.deepOrange,
            tabs: [
              Tab(icon: Icon(Icons.local_offer), text: 'Promo'),
              Tab(icon: Icon(Icons.fastfood), text: 'Makanan Saji'),
              Tab(icon: Icon(Icons.set_meal), text: 'Makanan Jepang'),
              Tab(icon: Icon(Icons.spa), text: 'Makanan Sehat'),
              Tab(icon: Icon(Icons.cake), text: 'Dessert'),
              Tab(icon: Icon(Icons.local_cafe), text: 'Minuman'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ProductListTab(filter: 'promo'),
                ProductListTab(filter: 'Makanan Saji'),
                ProductListTab(filter: 'Makanan Jepang'),
                ProductListTab(filter: 'Makanan Sehat'),
                ProductListTab(filter: 'Dessert'),
                ProductListTab(filter: 'Minuman'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductListTab extends StatefulWidget {
  final String filter;
  const ProductListTab({super.key, required this.filter});

  @override
  State<ProductListTab> createState() => _ProductListTabState();
}

class _ProductListTabState extends State<ProductListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final filtered = widget.filter == 'promo'
        ? CombinedMenuPage.allProducts.where((p) => p['isPromo'] == true).toList()
        : CombinedMenuPage.allProducts
            .where((p) => p['kategori'] == widget.filter)
            .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('Tidak ada produk.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildProductCard(context, filtered[index]);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final bool isPromo = product['isPromo'] == true && product['promoPrice'] != null;
    final int harga = product['harga'];
    final int? promoPrice = product['promoPrice'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              title: product['title'],
              description: product['description'],
              image: product['image'],
              harga: harga.toDouble(),
              promoPrice: promoPrice?.toDouble(), 
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(product['image']),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(child: Text(product['title'])),
                    if (isPromo)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'PROMO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['description']),
                    const SizedBox(height: 4),
                    isPromo
                        ? Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Rp $promoPrice ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Rp $harga',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Text(
                            'Rp $harga',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
