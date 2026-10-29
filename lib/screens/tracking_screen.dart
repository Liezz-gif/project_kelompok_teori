import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../utils/google_maps_helper.dart';
import '../widgets/embedded_google_map_view.dart';

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
      return Icons.check_circle;
    }

    String getStatusDesc(String status) {
      if (status == 'Diproses') return 'Pesanan sedang dimasak';
      if (status == 'Dikirim') return 'Pesanan sedang dalam perjalanan';
      return 'Pesanan telah sampai';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: orderData.orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Belum ada pesanan aktif.',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderData.orders.length,
              itemBuilder: (ctx, i) {
                final order = orderData.orders[i];
                final statusColor = getStatusColor(order.status);
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: status + order ID
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(getStatusIcon(order.status),
                                  color: statusColor, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order: ${order.id}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${order.products.length} item • Rp ${order.totalAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order.status,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          getStatusDesc(order.status),
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),

                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Alamat pengiriman
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on,
                                size: 18, color: Color(0xFFE65100)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Alamat Pengiriman',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    order.address,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Peta langsung sesuai alamat pesanan
                        EmbeddedGoogleMapView(
                          address: order.address,
                          selectedLocation: (order.latitude != null && order.longitude != null)
                              ? LatLng(order.latitude!, order.longitude!)
                              : null,
                          allowTapToPick: false,
                          onTapOpenFullMaps: () => openGoogleMaps(
                            address: order.address,
                            latitude: order.latitude,
                            longitude: order.longitude,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Tombol simulasi status
                        if (order.status == 'Diproses')
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .updateOrderStatus(
                                          order.id, 'Dikirim'),
                              icon: const Icon(Icons.delivery_dining,
                                  color: Colors.blue),
                              label: const Text('Simulasi: Ubah ke Dikirim',
                                  style: TextStyle(color: Colors.blue)),
                              style: OutlinedButton.styleFrom(
                                  side:
                                      const BorderSide(color: Colors.blue)),
                            ),
                          )
                        else if (order.status == 'Dikirim')
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .updateOrderStatus(
                                          order.id, 'Selesai'),
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.green),
                              label: const Text('Simulasi: Ubah ke Selesai',
                                  style: TextStyle(color: Colors.green)),
                              style: OutlinedButton.styleFrom(
                                  side:
                                      const BorderSide(color: Colors.green)),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
