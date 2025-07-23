import 'package:flutter/material.dart';
import 'package:myapp/component/food_model.dart';

class CartProvider with ChangeNotifier {
  final List<FoodItem> _items = [];

  List<FoodItem> get items => _items;

  void addToCart(FoodItem item) {
    final index = _items.indexWhere((i) =>
        i.name == item.name && i.variation == item.variation);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void decrease(FoodItem item) {
    final index = _items.indexWhere((i) =>
        i.name == item.name && i.variation == item.variation);

    if (index != -1) {
      final currentQty = _items[index].quantity;
      if (currentQty > 1) {
        _items[index] = _items[index].copyWith(quantity: currentQty - 1);
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(
      0,
      (sum, item) => sum + item.effectivePrice * item.quantity,
    );
  }
}
