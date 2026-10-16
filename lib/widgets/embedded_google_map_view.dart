import 'package:flutter/material.dart';

class EmbeddedGoogleMapView extends StatefulWidget {
  final String address;
  final VoidCallback onTapOpenFullMaps;

  const EmbeddedGoogleMapView({
    super.key,
    required this.address,
    required this.onTapOpenFullMaps,
  });

  @override
  State<EmbeddedGoogleMapView> createState() => _EmbeddedGoogleMapViewState();
}

class _EmbeddedGoogleMapViewState extends State<EmbeddedGoogleMapView> {
  double _zoomLevel = 15.0;
  bool _isSatellite = false;

  @override
  Widget build(BuildContext context) {
    final String displayAddress = widget.address.isEmpty
        ? 'Jl. Veteran No. 8, Lowokwaru, Kota Malang, Jawa Timur'
        : widget.address;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE65100).withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: const Color(0xFF4E342E),
              child: Row(
                children: [
                  const Icon(Icons.map, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Google Maps Live View',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.gps_fixed, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'GPS Aktif',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      _isSatellite
                          ? 'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&auto=format&fit=crop&q=80'
                          : 'https://images.unsplash.com/photo-1569336415962-a4bd9f69cd83?w=800&auto=format&fit=crop&q=80',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFE0E0E0),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE65100)),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFEFEBE9),
                          child: const Center(
                            child: Icon(Icons.map_outlined, size: 48, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.restaurant, size: 12, color: Color(0xFFE65100)),
                              const SizedBox(width: 4),
                              Text(
                                displayAddress.length > 25
                                    ? '${displayAddress.substring(0, 25)}...'
                                    : displayAddress,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 42,
                          shadows: [Shadow(blurRadius: 6, color: Colors.black38, offset: Offset(0, 3))],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'map_type',
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4E342E),
                          onPressed: () {
                            setState(() {
                              _isSatellite = !_isSatellite;
                            });
                          },
                          child: Icon(_isSatellite ? Icons.map : Icons.satellite_alt, size: 18),
                        ),
                        const SizedBox(height: 6),
                        FloatingActionButton.small(
                          heroTag: 'zoom_in',
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          onPressed: () {
                            setState(() {
                              _zoomLevel = (_zoomLevel + 1).clamp(10.0, 20.0);
                            });
                          },
                          child: const Icon(Icons.add, size: 18),
                        ),
                        const SizedBox(height: 6),
                        FloatingActionButton.small(
                          heroTag: 'zoom_out',
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          onPressed: () {
                            setState(() {
                              _zoomLevel = (_zoomLevel - 1).clamp(10.0, 20.0);
                            });
                          },
                          child: const Icon(Icons.remove, size: 18),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Zoom: ${_zoomLevel.toStringAsFixed(0)}x | ${_isSatellite ? "Satelit" : "Peta Jalan"}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              color: const Color(0xFFFAF6F0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFE65100)),
                      SizedBox(width: 6),
                      Text(
                        'Alamat Pengiriman Lengkap:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    displayAddress,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: widget.onTapOpenFullMaps,
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text(
                        'Buka Peta Penuh di Google Maps App',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
