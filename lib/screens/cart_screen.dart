import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/food_image_widget.dart';
import '../widgets/embedded_google_map_view.dart';
import '../utils/google_maps_helper.dart';
import '../services/location_service.dart';
import 'tracking_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressController = TextEditingController();
  final _addressFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  bool _showSuggestions = false;
  bool _isLoadingSuggestions = false;
  List<AddressLocationItem> _suggestions = [];
  Timer? _debounceTimer;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = Provider.of<UserProvider>(context, listen: false);
      if (_addressController.text.isEmpty && user.mainAddress.isNotEmpty) {
        setState(() {
          _addressController.text = user.mainAddress;
          _selectedLocation = user.mainLocation;
        });
      }
    });
    _addressFocusNode.addListener(() {
      if (!_addressFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() => _showSuggestions = false);
          }
        });
      }
    });
  }

  void _onAddressChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();

    // Jangan tampilkan saran atau pencarian jika kurang dari 2 karakter
    if (trimmed.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isLoadingSuggestions = false;
      });
      return;
    }

    // 1. Tampilkan rekomendasi lokal secara instan (0 delay)
    final localMatches = LocationService.searchLocal(trimmed);
    setState(() {
      _suggestions = localMatches;
      _showSuggestions = localMatches.isNotEmpty;
      _isLoadingSuggestions = localMatches.isEmpty && trimmed.length >= 3;
    });

    // 2. Debounce pencarian online hanya jika hasil lokal sedikit dan query >= 3 huruf
    if (trimmed.length >= 3 && localMatches.length < 2) {
      _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
        final results = await LocationService.searchLocations(trimmed);
        if (!mounted) return;

        // Cegah race condition: hanya perbarui jika pengguna belum mengetik hal lain
        if (_addressController.text.trim() == trimmed) {
          setState(() {
            _suggestions = results;
            _showSuggestions = results.isNotEmpty;
            _isLoadingSuggestions = false;
          });
        }
      });
    } else {
      setState(() => _isLoadingSuggestions = false);
    }
  }

  void _selectSuggestion(AddressLocationItem item) {
    _debounceTimer?.cancel();
    setState(() {
      _addressController.text = item.fullAddress;
      _selectedLocation = item.location;
      _showSuggestions = false;
      _isLoadingSuggestions = false;
    });
    _addressFocusNode.unfocus();
  }

  void _onFieldSubmitted(String value) {
    _debounceTimer?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    if (_suggestions.isNotEmpty) {
      _selectSuggestion(_suggestions.first);
      return;
    }

    final localMatches = LocationService.searchLocal(trimmed);
    if (localMatches.isNotEmpty) {
      _selectSuggestion(localMatches.first);
      return;
    }

    setState(() {
      _showSuggestions = false;
      _isLoadingSuggestions = false;
    });
    _addressFocusNode.unfocus();
  }

  void _onMapLocationPicked(LatLng newLocation, String resolvedAddress) {
    _debounceTimer?.cancel();
    setState(() {
      _selectedLocation = newLocation;
      _addressController.text = resolvedAddress;
      _showSuggestions = false;
      _isLoadingSuggestions = false;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _addressController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Keranjang Anda kosong.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- DAFTAR ITEM KERANJANG ---
                        const Text(
                          'Item Pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF4E342E),
                          ),
                        ),
                        const SizedBox(height: 8),

                        ...cartItems.map(
                          (item) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: buildMenuImage(
                                      imageUrl: item.imageUrl,
                                      menuId: item.productId,
                                      name: item.name,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Rp ${(item.price * item.quantity).toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: Color(0xFFE65100),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.grey,
                                          size: 22,
                                        ),
                                        onPressed: () =>
                                            cart.removeSingleItem(item.productId),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle,
                                          color: Color(0xFFE65100),
                                          size: 22,
                                        ),
                                        onPressed: () => cart.addItem(
                                          item.productId,
                                          item.price,
                                          item.name,
                                          item.imageUrl,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // --- BAGIAN DETAIL PENGIRIMAN ---
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.delivery_dining,
                                        color: Color(0xFFE65100)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Detail Pengiriman',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF4E342E),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Input Alamat & Lokasi
                                TextFormField(
                                  controller: _addressController,
                                  focusNode: _addressFocusNode,
                                  onChanged: _onAddressChanged,
                                  onFieldSubmitted: _onFieldSubmitted,
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                    hintText: 'Ketik nama tempat, asrama, atau jalan...',
                                    hintStyle: const TextStyle(fontSize: 13),
                                    filled: true,
                                    fillColor: const Color(0xFFFAF6F0),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.location_on,
                                      color: Color(0xFFE65100),
                                    ),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_addressController.text.isNotEmpty)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.clear,
                                              color: Colors.grey,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              _debounceTimer?.cancel();
                                              _addressController.clear();
                                              setState(() {
                                                _showSuggestions = false;
                                                _isLoadingSuggestions = false;
                                                _suggestions = [];
                                                _selectedLocation = null;
                                              });
                                            },
                                          ),
                                        if (_addressController.text.isNotEmpty)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.map,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                            tooltip: 'Buka di Google Maps',
                                            onPressed: () => openGoogleMaps(
                                              address: _addressController.text,
                                              latitude: _selectedLocation?.latitude,
                                              longitude: _selectedLocation?.longitude,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                          ? 'Alamat tujuan wajib diisi'
                                          : null,
                                ),

                                // Rekomendasi Alamat Sinkron (Hanya muncul jika >= 2 huruf)
                                if (_showSuggestions &&
                                    _addressController.text.trim().length >= 2)
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    constraints:
                                        const BoxConstraints(maxHeight: 220),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE65100)
                                            .withValues(alpha: 0.35),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: ListView(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 7,
                                            ),
                                            color: const Color(0xFFFFF3E0),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.travel_explore,
                                                  size: 14,
                                                  color: Color(0xFFE65100),
                                                ),
                                                const SizedBox(width: 6),
                                                const Expanded(
                                                  child: Text(
                                                    'Pilih Rekomendasi Lokasi:',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFFE65100),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                if (_isLoadingSuggestions)
                                                  const SizedBox(
                                                    width: 12,
                                                    height: 12,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Color(0xFFE65100),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (_suggestions.isEmpty &&
                                              !_isLoadingSuggestions)
                                            Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Tempat belum terdaftar dalam saran otomatis.',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  const Text(
                                                    'Tips: Anda dapat langsung mengetuk titik pada peta di bawah ini untuk menentukan lokasi pengantaran yang presisi.',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          else
                                            ..._suggestions.map((item) => ListTile(
                                                  dense: true,
                                                  leading: Icon(
                                                    item.isOnline
                                                        ? Icons.public
                                                        : Icons.location_on,
                                                    size: 18,
                                                    color: item.isOnline
                                                        ? Colors.blue
                                                        : const Color(0xFFE65100),
                                                  ),
                                                  title: Text(
                                                    item.title,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF4E342E),
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    item.subtitle,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey.shade700,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  trailing: const Icon(
                                                    Icons.north_west,
                                                    size: 14,
                                                    color: Colors.grey,
                                                  ),
                                                  onTap: () => _selectSuggestion(item),
                                                )),
                                        ],
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 8),

                                // Chip Rekomendasi Cepat
                                const Text(
                                  'Pilihan Cepat:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    _buildQuickChip(
                                      label: 'Asrama Putra ISBA',
                                      address:
                                          'Asrama Putra ISBA Malang, Jl. Terusan Margojoyo Jetis, Dau, Malang',
                                      location: const LatLng(-7.921698, 112.585910),
                                    ),
                                    _buildQuickChip(
                                      label: 'Univ Brawijaya (UB)',
                                      address:
                                          'Universitas Brawijaya (UB), Jl. Veteran No. 8, Lowokwaru, Malang',
                                      location: const LatLng(-7.952500, 112.614200),
                                    ),
                                    _buildQuickChip(
                                      label: 'Jl. Soekarno Hatta',
                                      address:
                                          'Jl. Soekarno Hatta, Lowokwaru, Kota Malang',
                                      location: const LatLng(-7.944200, 112.616700),
                                    ),
                                    _buildQuickChip(
                                      label: 'Jl. Veteran No. 8',
                                      address:
                                          'Jl. Veteran No. 8, Lowokwaru, Kota Malang',
                                      location: const LatLng(-7.952300, 112.614200),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Peta Interaktif
                                EmbeddedGoogleMapView(
                                  address: _addressController.text,
                                  selectedLocation: _selectedLocation,
                                  onLocationChanged: _onMapLocationPicked,
                                  onTapOpenFullMaps: () {
                                    final addr = _addressController.text.isNotEmpty
                                        ? _addressController.text
                                        : 'Malang, Jawa Timur';
                                    openGoogleMaps(
                                      address: addr,
                                      latitude: _selectedLocation?.latitude,
                                      longitude: _selectedLocation?.longitude,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // --- STICKY BOTTOM CHECKOUT BAR ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -4),
                      )
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Rp ${cart.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4E342E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Provider.of<OrderProvider>(context, listen: false)
                                    .addOrder(
                                  cartItems,
                                  cart.totalAmount,
                                  _addressController.text,
                                  latitude: _selectedLocation?.latitude,
                                  longitude: _selectedLocation?.longitude,
                                );
                                cart.clearCart();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TrackingScreen(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required String address,
    required LatLng location,
  }) {
    final bool isSelected = _addressController.text == address;
    return ActionChip(
      avatar: Icon(
        Icons.my_location,
        size: 15,
        color: isSelected ? Colors.white : const Color(0xFFE65100),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: isSelected ? const Color(0xFFE65100) : const Color(0xFFFFF3E0),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () {
        _debounceTimer?.cancel();
        setState(() {
          _addressController.text = address;
          _selectedLocation = location;
          _showSuggestions = false;
          _isLoadingSuggestions = false;
        });
        _addressFocusNode.unfocus();
      },
    );
  }
}
