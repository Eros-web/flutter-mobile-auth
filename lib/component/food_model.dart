class FoodItem {
  final String name;
  final double price;
  final double? promoPrice; // ✅ harga promo, nullable
  final String imageUrl;
  final String? variation;  // ✅ variasi, optional
  final int quantity;

  const FoodItem({
    required this.name,
    required this.price,
    this.promoPrice,
    required this.imageUrl,
    this.variation,
    this.quantity = 1,
  });

  /// ✅ Getter harga akhir (prioritas promo)
  double get effectivePrice => promoPrice ?? price;

  /// ✅ Buat salin item dengan quantity baru
  FoodItem copyWith({int? quantity}) {
    return FoodItem(
      name: name,
      price: price,
      promoPrice: promoPrice,
      imageUrl: imageUrl,
      variation: variation,
      quantity: quantity ?? this.quantity,
    );
  }

  /// ✅ Konversi dari JSON
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      promoPrice: json['promoPrice'] != null ? (json['promoPrice'] as num).toDouble() : null,
      imageUrl: json['imageUrl'],
      variation: json['variation'],
      quantity: json['quantity'] ?? 1,
    );
  }

  /// ✅ Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'promoPrice': promoPrice,
      'imageUrl': imageUrl,
      'variation': variation,
      'quantity': quantity,
    };
  }

  /// ✅ Equality supaya item unik (berdasarkan name & variation)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          variation == other.variation;

  @override
  int get hashCode => name.hashCode ^ (variation?.hashCode ?? 0);
}
