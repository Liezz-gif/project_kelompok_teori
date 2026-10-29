import 'cart_item_model.dart';

class Order {
  final String id;
  final String address;
  final double totalAmount;
  final List<CartItem> products;
  final DateTime dateTime;
  final double? latitude;
  final double? longitude;
  String status;

  Order({
    required this.id,
    required this.address,
    required this.totalAmount,
    required this.products,
    required this.dateTime,
    this.latitude,
    this.longitude,
    this.status = 'Diproses',
  });
}
