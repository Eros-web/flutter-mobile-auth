enum VoucherType {
  productDiscount,
  freeDelivery,
}

class Voucher {
  final String code;
  final String description;
  final String? applicableProduct;
  final int discountAmount;
  final VoucherType type;
  final double? minPurchase;

  Voucher({
    required this.code,
    required this.description,
    this.applicableProduct,
    required this.discountAmount,
    required this.type,
    this.minPurchase,
  });
}
