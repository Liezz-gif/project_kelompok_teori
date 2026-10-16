import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;
  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) => total += cartItem.price * cartItem.quantity);
    return total;
  }

  void addItem(String productId, double price, String name, String imageUrl) {
    if (_items.containsKey(productId)) {
      _items.update(productId, (existing) => CartItem(
        id: existing.id,
        productId: existing.productId,
        name: existing.name,
        imageUrl: existing.imageUrl,
        price: existing.price,
        quantity: existing.quantity + 1,
      ));
    } else {
      _items.putIfAbsent(productId, () => CartItem(
        id: DateTime.now().toString(),
        productId: productId,
        name: name,
        imageUrl: imageUrl,
        price: price,
        quantity: 1,
      ));
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(productId, (existing) => CartItem(
        id: existing.id,
        productId: existing.productId,
        name: existing.name,
        imageUrl: existing.imageUrl,
        price: existing.price,
        quantity: existing.quantity - 1,
      ));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }
}
