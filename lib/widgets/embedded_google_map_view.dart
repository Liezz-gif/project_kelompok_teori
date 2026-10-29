import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EmbeddedGoogleMapView extends StatelessWidget {
  final String address;
  final VoidCallback onTapOpenFullMaps;

  const EmbeddedGoogleMapView({
    super.key,
    required this.address,
    required this.onTapOpenFullMaps,
  });

  @override
  Widget build(BuildContext context) {
    // Titik koordinat tengah kota Malang (Sekitar Jl. Veteran / UB)
    final malangCenter = const LatLng(-7.9553, 112.6115);

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: malangCenter,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.project_kelompok_teori',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: malangCenter,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: ElevatedButton.icon(
                onPressed: onTapOpenFullMaps,
                icon: const Icon(Icons.map),
                label: const Text('Buka Peta Penuh', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}