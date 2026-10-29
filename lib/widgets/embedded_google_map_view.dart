import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';

class EmbeddedGoogleMapView extends StatefulWidget {
  final String address;
  final LatLng? selectedLocation;
  final void Function(LatLng location, String address)? onLocationChanged;
  final VoidCallback onTapOpenFullMaps;
  final bool allowTapToPick;
  final double height;

  const EmbeddedGoogleMapView({
    super.key,
    required this.address,
    this.selectedLocation,
    this.onLocationChanged,
    required this.onTapOpenFullMaps,
    this.allowTapToPick = true,
    this.height = 240,
  });

  @override
  State<EmbeddedGoogleMapView> createState() => _EmbeddedGoogleMapViewState();
}

class _EmbeddedGoogleMapViewState extends State<EmbeddedGoogleMapView> {
  final MapController _mapController = MapController();

  late LatLng _currentPoint;
  bool _isLoading = false;
  bool _hasResult = false;
  String _lastAddress = '';
  double _currentZoom = 16.0;

  @override
  void initState() {
    super.initState();
    if (widget.selectedLocation != null) {
      _currentPoint = widget.selectedLocation!;
      _hasResult = true;
      _currentZoom = 16.5;
    } else if (widget.address.trim().isNotEmpty) {
      _currentPoint = LocationService.malangDefaultCenter;
      _updateLocationFromAddress(widget.address);
    } else {
      _currentPoint = LocationService.malangDefaultCenter;
      _hasResult = false;
      _currentZoom = 13.5;
    }
  }

  @override
  void didUpdateWidget(EmbeddedGoogleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 1. Jika lokasi eksplisit diberikan atau berubah dari parent
    if (widget.selectedLocation != null &&
        widget.selectedLocation != oldWidget.selectedLocation) {
      setState(() {
        _currentPoint = widget.selectedLocation!;
        _hasResult = true;
        _isLoading = false;
      });
      _safeMoveMap(_currentPoint, 16.5);
      return;
    }

    // 2. Jika tidak ada explicit location, tapi teks alamat berubah
    // Hanya lakukan geocode internal jika alamat berubah dan selectedLocation kosong
    if (widget.selectedLocation == null &&
        widget.address != oldWidget.address &&
        widget.address.trim().isNotEmpty &&
        widget.address != _lastAddress) {
      _updateLocationFromAddress(widget.address);
    } else if (widget.address.trim().isEmpty && widget.selectedLocation == null) {
      setState(() {
        _currentPoint = LocationService.malangDefaultCenter;
        _hasResult = false;
        _isLoading = false;
        _lastAddress = '';
      });
      _safeMoveMap(LocationService.malangDefaultCenter, 13.5);
    }
  }

  void _safeMoveMap(LatLng target, double zoom) {
    _currentZoom = zoom;
    try {
      _mapController.move(target, zoom);
    } catch (_) {
      // MapController belum siap, abaikan
    }
  }

  Future<void> _updateLocationFromAddress(String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty || trimmed.length < 3) return;

    if (trimmed == _lastAddress && _hasResult) return;
    _lastAddress = trimmed;

    // Cek lokal database dulu (sangat cepat)
    final localMatches = LocationService.searchLocal(trimmed);
    if (localMatches.isNotEmpty) {
      final loc = localMatches.first.location;
      if (!mounted) return;
      setState(() {
        _currentPoint = loc;
        _hasResult = true;
        _isLoading = false;
      });
      _safeMoveMap(loc, 16.5);
      // PENTING: JANGAN panggil onLocationChanged di sini agar tidak menimpa ketikan pengguna!
      return;
    }

    // Cari secara online jika belum ditemukan di lokal
    if (!mounted) return;
    setState(() => _isLoading = true);

    final results = await LocationService.searchLocations(trimmed);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (results.isNotEmpty) {
        _currentPoint = results.first.location;
        _hasResult = true;
        _safeMoveMap(_currentPoint, 16.5);
        // PENTING: JANGAN panggil onLocationChanged di sini!
      } else {
        if (!_hasResult) {
          _currentPoint = LocationService.malangDefaultCenter;
          _safeMoveMap(LocationService.malangDefaultCenter, 13.5);
        }
      }
    });
  }

  /// PENTING: onLocationChanged HANYA dipanggil saat pengguna sengaja mengetuk peta
  Future<void> _handleMapTap(TapPosition tapPosition, LatLng point) async {
    if (!widget.allowTapToPick) return;

    setState(() {
      _currentPoint = point;
      _hasResult = true;
      _isLoading = true;
    });
    _safeMoveMap(point, _currentZoom);

    // Dapatkan nama alamat dari titik yang diketuk
    final resolvedAddress = await LocationService.reverseGeocode(point);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (resolvedAddress != null) {
      widget.onLocationChanged?.call(point, resolvedAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.address.trim().isEmpty && widget.selectedLocation == null;

    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasResult
              ? const Color(0xFFE65100).withValues(alpha: 0.6)
              : Colors.grey.shade300,
          width: _hasResult ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Peta interaktif
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPoint,
                initialZoom: _currentZoom,
                onTap: _handleMapTap,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.project_kelompok_teori',
                  errorImage: const AssetImage('assets/map_placeholder.png'),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPoint,
                      width: 50,
                      height: 50,
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_pin,
                            key: ValueKey(_currentPoint),
                            color: _hasResult
                                ? const Color(0xFFE65100)
                                : Colors.grey.shade700,
                            size: 44,
                            shadows: const [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Top banner: status alamat / petunjuk ketuk
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _hasResult ? Icons.place : Icons.touch_app,
                      color: _hasResult ? const Color(0xFFE65100) : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.address.isNotEmpty
                                ? widget.address
                                : 'Ketuk peta untuk menentukan titik lokasi',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4E342E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.allowTapToPick)
                            Text(
                              _hasResult
                                  ? 'Titik GPS: ${_currentPoint.latitude.toStringAsFixed(4)}, ${_currentPoint.longitude.toStringAsFixed(4)} (Ketuk peta untuk ubah)'
                                  : 'Geser & ketuk peta untuk memilih lokasi tepat',
                              style: TextStyle(
                                fontSize: 10,
                                color: _hasResult
                                    ? Colors.grey.shade700
                                    : const Color(0xFFE65100),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE65100),
                        ),
                      )
                    else if (_hasResult)
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 16),
                  ],
                ),
              ),
            ),

            // Tombol Zoom In & Zoom Out
            Positioned(
              right: 10,
              top: 70,
              child: Column(
                children: [
                  _buildMapActionButton(
                    icon: Icons.add,
                    tooltip: 'Perbesar peta',
                    onPressed: () {
                      _safeMoveMap(_currentPoint, (_currentZoom + 1).clamp(3.0, 18.0));
                    },
                  ),
                  const SizedBox(height: 6),
                  _buildMapActionButton(
                    icon: Icons.remove,
                    tooltip: 'Perkecil peta',
                    onPressed: () {
                      _safeMoveMap(_currentPoint, (_currentZoom - 1).clamp(3.0, 18.0));
                    },
                  ),
                ],
              ),
            ),

            // Placeholder jika belum ada alamat sama sekali
            if (isEmpty && !_hasResult)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.25),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app, color: Colors.white, size: 36),
                          SizedBox(height: 6),
                          Text(
                            'Ketik alamat atau ketuk langsung di peta\nuntuk menentukan lokasi pengiriman',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Tombol Buka di Google Maps
            Positioned(
              bottom: 8,
              left: 10,
              right: 10,
              child: ElevatedButton.icon(
                onPressed: widget.onTapOpenFullMaps,
                icon: const Icon(Icons.map, size: 16),
                label: const Text(
                  'Buka di Google Maps',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: const Color(0xFF4E342E)),
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}
