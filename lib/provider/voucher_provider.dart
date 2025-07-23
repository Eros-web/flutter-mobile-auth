import 'package:flutter/material.dart';

class VoucherProvider with ChangeNotifier {
  // Daftar promo aktif
  List<Map<String, dynamic>> _availablePromos = [];

  // Voucher manual
  String? _selectedCode;
  double _discount = 0.0;

  // Diskon otomatis (tanpa kode)
  double _autoDiscount = 0.0;

  // Promo gratis ongkir
  bool _hasFreeShipping = false;

  // Setter: kirim semua promo (baik autoApply maupun manual)
  void setPromos(List<Map<String, dynamic>> promos) {
    _availablePromos = promos;
    notifyListeners();
  }

  // Getters
  double get discount => _discount;
  double get autoDiscount => _autoDiscount;
  double get totalDiscount => _discount + _autoDiscount;

  String? get selectedCode => _selectedCode;
  List<Map<String, dynamic>> get availablePromos => _availablePromos;

  bool get hasFreeShipping => _hasFreeShipping;

  // Terapkan voucher manual berdasarkan kode
  void applyVoucher(
    String code,
    double orderTotal, {
    DateTime? now,
    String? selectedMenu,
  }) {
    print('Menerapkan voucher: $code dengan total pesanan: $orderTotal');

    final promo = _availablePromos.firstWhere(
      (p) => p['code'] == code,
      orElse: () => {},
    );

    if (promo.isEmpty) {
      print('❌ Promo tidak ditemukan');
      _resetVoucher();
      return;
    }

    final type = promo['type'];
    final value = promo['value'];
    final conditions = promo['conditions'] ?? {};
    now ??= DateTime.now();

    // Validasi: minimal order
    if (conditions['minOrder'] != null &&
        orderTotal < (conditions['minOrder'] as num).toDouble()) {
      print('❌ Gagal: Total order kurang dari minimum ${conditions['minOrder']}');
      _resetVoucher();
      return;
    }

    // Validasi: maksimal jam
    if (conditions['maxHour'] != null &&
        now.hour >= (conditions['maxHour'] as int)) {
      print('❌ Gagal: Sudah lewat jam promo (${now.hour} >= ${conditions['maxHour']})');
      _resetVoucher();
      return;
    }

    // Validasi: menu harus mengandung keyword
    if (conditions['menuKeyword'] != null) {
      final keyword = (conditions['menuKeyword'] as String).toLowerCase();
      final menuLower = selectedMenu?.toLowerCase() ?? '';
      if (!menuLower.contains(keyword)) {
        print('❌ Gagal: Menu tidak mengandung keyword "$keyword"');
        _resetVoucher();
        return;
      }
    }

    // ✅ Lolos semua validasi
    _selectedCode = code;
    if (type == 'percent') {
      _discount = ((value as num).toDouble() / 100.0) * orderTotal;
    } else {
      _discount = (value as num).toDouble();
    }

    print('✅ Diskon berhasil diterapkan: $_discount');
    notifyListeners();
  }

  // Terapkan promo otomatis (tanpa kode)
  void applyAutoPromos(double orderTotal, {DateTime? now}) {
    _autoDiscount = 0.0;
    _hasFreeShipping = false;
    now ??= DateTime.now();

    for (var promo in _availablePromos) {
      if (promo['autoApply'] != true) continue;

      final type = promo['type'];
      final value = (promo['value'] ?? 0).toDouble();
      final minOrder = (promo['minOrder'] ?? 0).toDouble();

      if (orderTotal < minOrder) continue;

      if (type == 'percent') {
        _autoDiscount += (value / 100.0) * orderTotal;
      } else if (type == 'amount') {
        _autoDiscount += value;
      } else if (type == 'free_shipping') {
        _hasFreeShipping = true;
      }
    }

    print('✅ Diskon otomatis dihitung: $_autoDiscount, Free shipping: $_hasFreeShipping');
    notifyListeners();
  }

  void clearVoucher() {
    _resetVoucher();
    notifyListeners();
  }

  void _resetVoucher() {
    _selectedCode = null;
    _discount = 0.0;
    _hasFreeShipping = false;
  }

  bool isVoucherValid(String code) {
    return _availablePromos.any((p) => p['code'] == code);
  }

  String getVoucherDescription(String code) {
    return _availablePromos.firstWhere(
      (p) => p['code'] == code,
      orElse: () => {},
    )['description'] ?? '';
  }
}
