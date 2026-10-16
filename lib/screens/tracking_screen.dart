import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../utils/google_maps_helper.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<OrderProvider>(context);

    Color getStatusColor(String status) {
      if (status == 'Diproses') return const Color(0xFFE65100);
      if (status == 'Dikirim') return Colors.blue;
      return Colors.green;
    }

    IconData getStatusIcon(String status) {
      if (status == 'Diproses') return Icons.soup_kitchen;
      if (status == 'Dikirim') return Icons.delivery_dining;
      return Icons.check_box;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: orderData.orders.isEmpty
          ? const Center(child: Text('Belum ada pesanan aktif.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderData.orders.length,
              itemBuilder: (ctx, i) {
                final order = orderData.orders[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: getStatusColor(order.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(getStatusIcon(order.status), color: getStatusColor(order.status), size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Order: ${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('${order.products.length} Items • Rp ${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: getStatusColor(order.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(order.status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order.address,
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              onPressed: () => openGoogleMaps(order.address),
                              icon: const Icon(Icons.map, size: 16, color: Colors.redAccent),
                              label: const Text('Lacak di Maps', style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        if (order.status == 'Diproses')
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Provider.of<OrderProvider>(context, listen: false).updateOrderStatus(order.id, 'Dikirim'),
                              child: const Text('Simulasi: Ubah ke Dikirim'),
                            ),
                          )
                        else if (order.status == 'Dikirim')
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Provider.of<OrderProvider>(context, listen: false).updateOrderStatus(order.id, 'Selesai'),
                              child: const Text('Simulasi: Ubah ke Selesai'),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
