import 'cart_item_model.dart';

class Order {
  final String id, address;
  final double totalAmount;
  final List<CartItem> products;
  final DateTime dateTime;
  String status;

  Order({
    required this.id,
    required this.address,
    required this.totalAmount,
    required this.products,
    required this.dateTime,
    this.status = 'Diproses',
  });
}
