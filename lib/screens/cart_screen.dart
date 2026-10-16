import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/food_image_widget.dart';
import '../widgets/embedded_google_map_view.dart';
import '../utils/google_maps_helper.dart';
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

  static const List<String> _addressDatabase = [
    'Jl. Veteran No. 8, Lowokwaru, Malang',
    'Jl. Veteran No. 12, Lowokwaru, Malang',
    'Jl. Soekarno Hatta No. 9, Jatimulyo, Malang',
    'Jl. Soekarno Hatta No. 24, Jatimulyo, Malang',
    'Jl. Kawi No. 24, Kauman, Malang',
    'Jl. Besar Ijen No. 10, Gading Kasri, Malang',
    'Jl. Bendungan Sutami No. 15, Sumbersari, Malang',
    'Jl. Dinoyo No. 45, Lowokwaru, Malang',
    'Jl. Borobudur No. 18, Blimbing, Malang',
    'Jl. Mt. Haryono No. 169, Dinoyo, Malang',
    'Jl. Terusan Surabaya No. 6, Sumbersari, Malang',
    'Jl. Mayjend Panjaitan No. 88, Penanggungan, Malang',
    'Universitas Brawijaya, Jl. Veteran, Malang',
    'Universitas Negeri Malang, Jl. Semarang No. 5, Malang',
    'Malang Town Square (Matos), Jl. Veteran, Malang',
    'Olympic Garden Mall (MOG), Jl. Tenes, Malang',
    'Alun-Alun Kota Malang, Jl. Merdeka Selatan, Malang',
    'Pasar Besar Malang, Jl. Pasar Besar, Malang',
    'Stasiun Malang Kotabaru, Jl. Trunojoyo, Malang',
  ];

  List<String> get _filteredSuggestions {
    final query = _addressController.text.trim();
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();
    final matches = _addressDatabase
        .where((address) => address.toLowerCase().contains(queryLower))
        .toList();

    if (matches.isEmpty) {
      final String formattedQuery = query.toLowerCase().startsWith('jl')
          ? query
          : 'Jl. $query';

      return [
        '$query, Malang, Jawa Timur',
        '$formattedQuery, Kota Malang',
        '$query, Indonesia',
      ];
    }

    return matches;
  }

  @override
  void dispose() {
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
          ? const Center(child: Text('Keranjang Anda kosong.', style: TextStyle(fontSize: 16, color: Colors.grey)))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (ctx, i) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: buildMenuImage(
                          imageUrl: cartItems[i].imageUrl,
                          menuId: cartItems[i].productId,
                          name: cartItems[i].name,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cartItems[i].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Rp ${(cartItems[i].price * cartItems[i].quantity).toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                            onPressed: () => cart.removeSingleItem(cartItems[i].productId),
                          ),
                          Text('${cartItems[i].quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Color(0xFFE65100)),
                            onPressed: () => cart.addItem(
                              cartItems[i].productId,
                              cartItems[i].price,
                              cartItems[i].name,
                              cartItems[i].imageUrl,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Detail Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      focusNode: _addressFocusNode,
                      onChanged: (text) {
                        setState(() {
                          _showSuggestions = text.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Ketik alamat/lokasi...',
                        filled: true,
                        fillColor: const Color(0xFFFAF6F0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.location_on, color: Color(0xFFE65100)),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_addressController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                                onPressed: () {
                                  _addressController.clear();
                                  setState(() {
                                    _showSuggestions = false;
                                  });
                                },
                              ),
                            if (_addressController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.map, color: Colors.redAccent),
                                tooltip: 'Buka di Google Maps',
                                onPressed: () => openGoogleMaps(_addressController.text),
                              ),
                          ],
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Alamat wajib diisi' : null,
                    ),
                    if (_showSuggestions && _addressController.text.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE65100).withValues(alpha: 0.3)),
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
                              if (!_addressDatabase.any((a) => a.toLowerCase().contains(_addressController.text.trim().toLowerCase())))
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  color: const Color(0xFFFFF3E0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.travel_explore, size: 14, color: Color(0xFFE65100)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Saran Google Maps untuk "${_addressController.text}":',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFFE65100), fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ..._filteredSuggestions.map((suggestion) => ListTile(
                                dense: true,
                                leading: const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFFE65100)),
                                title: Text(
                                  suggestion,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                trailing: const Icon(Icons.north_west, size: 14, color: Colors.grey),
                                onTap: () {
                                  setState(() {
                                    _addressController.text = suggestion;
                                    _showSuggestions = false;
                                  });
                                  _addressFocusNode.unfocus();
                                },
                              )),
                              ListTile(
                                dense: true,
                                leading: const Icon(Icons.map, size: 18, color: Colors.redAccent),
                                title: Text(
                                  'Cari "${_addressController.text}" di Google Maps',
                                  style: const TextStyle(fontSize: 13, color: Colors.redAccent, fontWeight: FontWeight.bold),
                                ),
                                trailing: const Icon(Icons.open_in_new, size: 14, color: Colors.redAccent),
                                onTap: () {
                                  setState(() {
                                    _showSuggestions = false;
                                  });
                                  openGoogleMaps(_addressController.text);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.my_location, size: 16, color: Color(0xFFE65100)),
                          label: const Text('Jl. Veteran No. 8, Malang', style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            setState(() {
                              _addressController.text = 'Jl. Veteran No. 8, Lowokwaru, Malang';
                              _showSuggestions = false;
                            });
                          },
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.my_location, size: 16, color: Color(0xFFE65100)),
                          label: const Text('Jl. Soekarno Hatta, Malang', style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            setState(() {
                              _addressController.text = 'Jl. Soekarno Hatta No. 9, Jatimulyo, Malang';
                              _showSuggestions = false;
                            });
                          },
                        ),
                      ],
                    ),
                    EmbeddedGoogleMapView(
                      address: _addressController.text,
                      onTapOpenFullMaps: () {
                        if (_addressController.text.isNotEmpty) {
                          openGoogleMaps(_addressController.text);
                        } else {
                          openGoogleMaps('Malang, Jawa Timur');
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Text('Rp ${cart.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Provider.of<OrderProvider>(context, listen: false).addOrder(
                            cartItems,
                            cart.totalAmount,
                            _addressController.text,
                          );
                          cart.clearCart();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const TrackingScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Checkout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
