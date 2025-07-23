import 'package:flutter/material.dart';
import 'food_model.dart'; // Import FoodItem

class CartModel extends ChangeNotifier {
  final List<FoodItem> _items = [];

  List<FoodItem> get items => List.unmodifiable(_items);

  double get totalPrice =>
      _items.fold(0, (total, item) => total + item.price * item.quantity);

  void add(FoodItem item) {
    final index = _items.indexWhere((e) => e == item);
    if (index != -1) {
      // Item sudah ada → tambahkan quantity
      final existing = _items[index];
      _items[index] = existing.copyWith(quantity: existing.quantity + item.quantity);
    } else {
      // Item belum ada → tambahkan baru
      _items.add(item);
    }
    notifyListeners();
  }

  void remove(FoodItem item) {
    _items.removeWhere((e) => e == item);
    notifyListeners();
  }

  void decrease(FoodItem item) {
    final index = _items.indexWhere((e) => e == item);
    if (index != -1) {
      final current = _items[index];
      if (current.quantity > 1) {
        _items[index] = current.copyWith(quantity: current.quantity - 1);
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
