import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];
  List<Order> get orders => [..._orders];

  void addOrder(List<CartItem> cartProducts, double total, String address) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final suffix = timestamp.length >= 6 ? timestamp.substring(timestamp.length - 6) : timestamp;
    _orders.insert(0, Order(
      id: 'ORD-$suffix',
      address: address,
      totalAmount: total,
      products: cartProducts,
      dateTime: DateTime.now(),
    ));
    notifyListeners();
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex >= 0) {
      _orders[orderIndex].status = newStatus;
      notifyListeners();
    }
  }
}
