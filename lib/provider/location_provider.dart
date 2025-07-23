import 'package:flutter/foundation.dart';

class LocationProvider with ChangeNotifier {
  final List<String> _addresses = [];
  String? _outlet;
  String _method = 'Pickup';

  List<String> get addresses => _addresses;
  String? get outlet => _outlet;
  String get method => _method;

  String? get address => _addresses.isNotEmpty ? _addresses.last : null;

  String? get location {
    return _method.toLowerCase() == 'delivery'
        ? (_addresses.isNotEmpty ? _addresses.last : null)
        : _outlet;
  }

  /// ✅ Tambah alamat (Delivery) - input aman
  void addAddress(String address) {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return;

    if (_addresses.isEmpty || _addresses.last != trimmed) {
      _addresses.add(trimmed);
      notifyListeners();
    }
  }

  /// ✅ Hapus alamat
  void removeAddress(int index) {
    if (index >= 0 && index < _addresses.length) {
      _addresses.removeAt(index);
      notifyListeners();
    }
  }

  /// ✅ Set outlet (Pickup)
  void setOutlet(String outlet) {
    final trimmed = outlet.trim();
    if (trimmed.isEmpty) return;

    if (_outlet != trimmed) {
      _outlet = trimmed;
      notifyListeners();
    }
  }

  /// ✅ Update aman anti-loop, input aman
  void updateSafe(String? location, String newMethod, {String? outlet}) {
    final lowerMethod = newMethod.toLowerCase();

    if (!['delivery', 'pickup', 'dine in'].contains(lowerMethod)) {
      return;
    }

    bool hasChanged = false;

    if (_method != newMethod) {
      _method = newMethod;
      hasChanged = true;
    }

    if (lowerMethod == 'delivery') {
      final trimmedLoc = location?.trim();
      if (trimmedLoc != null && trimmedLoc.isNotEmpty) {
        if (_addresses.isEmpty || _addresses.last != trimmedLoc) {
          _addresses.add(trimmedLoc);
          hasChanged = true;
        }
      }

      final trimmedOutlet = outlet?.trim();
      if (trimmedOutlet != null && trimmedOutlet.isNotEmpty && _outlet != trimmedOutlet) {
        _outlet = trimmedOutlet;
        hasChanged = true;
      }
    } else {
      final trimmedLoc = location?.trim();
      if (trimmedLoc != null && trimmedLoc.isNotEmpty && _outlet != trimmedLoc) {
        _outlet = trimmedLoc;
        hasChanged = true;
      }

      if (_addresses.isNotEmpty) {
        _addresses.clear();
        hasChanged = true;
      }
    }

    if (hasChanged) {
      notifyListeners();
    }
  }

  /// ✅ Reset total
  void reset() {
    _method = 'Pickup';
    _addresses.clear();
    _outlet = null;
    notifyListeners();
  }

  @override
  String toString() {
    return 'Method: $_method, Addresses: $_addresses, Outlet: $_outlet';
  }
}
