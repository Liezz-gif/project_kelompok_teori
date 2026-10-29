import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/order_provider.dart';
import '../providers/menu_provider.dart';
import '../widgets/food_image_widget.dart';
import '../widgets/embedded_google_map_view.dart';
import '../utils/google_maps_helper.dart';
import '../services/location_service.dart';
import 'login_screen.dart';
import 'detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _openAlamatPengiriman(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final addressController =
        TextEditingController(text: userProvider.mainAddress);
    LatLng selectedLocation = userProvider.mainLocation;
    List<AddressLocationItem> suggestions = [];
    bool showSuggestions = false;
    bool isLoadingSuggestions = false;
    Timer? debounceTimer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          void onAddressChanged(String query) {
            debounceTimer?.cancel();
            final trimmed = query.trim();
            if (trimmed.length < 2) {
              setModalState(() {
                suggestions = [];
                showSuggestions = false;
                isLoadingSuggestions = false;
              });
              return;
            }

            final localMatches = LocationService.searchLocal(trimmed);
            setModalState(() {
              suggestions = localMatches;
              showSuggestions = localMatches.isNotEmpty;
              isLoadingSuggestions = localMatches.isEmpty && trimmed.length >= 3;
            });

            if (trimmed.length >= 3 && localMatches.length < 2) {
              debounceTimer = Timer(const Duration(milliseconds: 400), () async {
                final results = await LocationService.searchLocations(trimmed);
                if (addressController.text.trim() == trimmed) {
                  setModalState(() {
                    suggestions = results;
                    showSuggestions = results.isNotEmpty;
                    isLoadingSuggestions = false;
                  });
                }
              });
            } else {
              setModalState(() => isLoadingSuggestions = false);
            }
          }

          void selectSuggestion(AddressLocationItem item) {
            debounceTimer?.cancel();
            setModalState(() {
              addressController.text = item.fullAddress;
              selectedLocation = item.location;
              showSuggestions = false;
              isLoadingSuggestions = false;
            });
          }

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            padding: EdgeInsets.only(
              top: 16,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header title
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Color(0xFFE65100), size: 26),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alamat Utama Pengiriman',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4E342E),
                              ),
                            ),
                            Text(
                              'Edit alamat & integrasi titik Google Maps',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          debounceTimer?.cancel();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Input edit alamat
                  TextFormField(
                    controller: addressController,
                    onChanged: onAddressChanged,
                    decoration: InputDecoration(
                      labelText: 'Ketik / Edit Alamat Pengiriman',
                      hintText: 'Nama jalan, asrama, atau gedung...',
                      filled: true,
                      fillColor: const Color(0xFFFAF6F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.edit_location_alt,
                          color: Color(0xFFE65100)),
                      suffixIcon: addressController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  size: 20, color: Colors.grey),
                              onPressed: () {
                                debounceTimer?.cancel();
                                addressController.clear();
                                setModalState(() {
                                  showSuggestions = false;
                                  isLoadingSuggestions = false;
                                  suggestions = [];
                                });
                              },
                            )
                          : null,
                    ),
                  ),

                  // Rekomendasi otomatis saat mengetik
                  if (showSuggestions &&
                      addressController.text.trim().length >= 2)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      constraints: const BoxConstraints(maxHeight: 180),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              const Color(0xFFE65100).withValues(alpha: 0.35),
                        ),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3)),
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
                                  horizontal: 10, vertical: 6),
                              color: const Color(0xFFFFF3E0),
                              child: Row(
                                children: [
                                  const Icon(Icons.travel_explore,
                                      size: 14, color: Color(0xFFE65100)),
                                  const SizedBox(width: 6),
                                  const Expanded(
                                    child: Text(
                                      'Pilih Rekomendasi:',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE65100),
                                      ),
                                    ),
                                  ),
                                  if (isLoadingSuggestions)
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
                            ...suggestions.map(
                              (item) => ListTile(
                                dense: true,
                                leading: Icon(
                                  item.isOnline
                                      ? Icons.public
                                      : Icons.location_on,
                                  size: 16,
                                  color: item.isOnline
                                      ? Colors.blue
                                      : const Color(0xFFE65100),
                                ),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  item.subtitle,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => selectSuggestion(item),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Chip Rekomendasi Cepat
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.my_location,
                            size: 14, color: Color(0xFFE65100)),
                        label: const Text('Asrama ISBA',
                            style: TextStyle(fontSize: 11)),
                        backgroundColor: const Color(0xFFFFF3E0),
                        side: BorderSide.none,
                        onPressed: () {
                          setModalState(() {
                            addressController.text =
                                'Asrama Putra ISBA Malang, Jl. Terusan Margojoyo Jetis, Dau, Malang';
                            selectedLocation =
                                const LatLng(-7.921698, 112.585910);
                            showSuggestions = false;
                          });
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.my_location,
                            size: 14, color: Color(0xFFE65100)),
                        label: const Text('Univ Brawijaya',
                            style: TextStyle(fontSize: 11)),
                        backgroundColor: const Color(0xFFFFF3E0),
                        side: BorderSide.none,
                        onPressed: () {
                          setModalState(() {
                            addressController.text =
                                'Universitas Brawijaya (UB), Jl. Veteran No. 8, Lowokwaru, Malang';
                            selectedLocation =
                                const LatLng(-7.952500, 112.614200);
                            showSuggestions = false;
                          });
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.my_location,
                            size: 14, color: Color(0xFFE65100)),
                        label: const Text('Jl. Suhat',
                            style: TextStyle(fontSize: 11)),
                        backgroundColor: const Color(0xFFFFF3E0),
                        side: BorderSide.none,
                        onPressed: () {
                          setModalState(() {
                            addressController.text =
                                'Jl. Soekarno Hatta No. 9, Jatimulyo, Malang';
                            selectedLocation =
                                const LatLng(-7.944200, 112.616700);
                            showSuggestions = false;
                          });
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.my_location,
                            size: 14, color: Color(0xFFE65100)),
                        label: const Text('Jl. Veteran',
                            style: TextStyle(fontSize: 11)),
                        backgroundColor: const Color(0xFFFFF3E0),
                        side: BorderSide.none,
                        onPressed: () {
                          setModalState(() {
                            addressController.text =
                                'Jl. Veteran No. 8, Lowokwaru, Malang';
                            selectedLocation =
                                const LatLng(-7.952300, 112.614200);
                            showSuggestions = false;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Peta Interaktif Terintegrasi dengan Google Maps
                  EmbeddedGoogleMapView(
                    address: addressController.text,
                    selectedLocation: selectedLocation,
                    height: 200,
                    onLocationChanged: (newLoc, resolvedAddr) {
                      setModalState(() {
                        selectedLocation = newLoc;
                        addressController.text = resolvedAddr;
                        showSuggestions = false;
                      });
                    },
                    onTapOpenFullMaps: () {
                      final addr = addressController.text.isNotEmpty
                          ? addressController.text
                          : 'Malang, Jawa Timur';
                      openGoogleMaps(
                        address: addr,
                        latitude: selectedLocation.latitude,
                        longitude: selectedLocation.longitude,
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // Pilihan Alamat Tersimpan
                  const Text(
                    'Pilihan Alamat Tersimpan:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...userProvider.savedAddresses.map((addr) {
                    final isCurrent = addr == addressController.text;
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          addressController.text = addr;
                          final match = LocationService.searchLocal(addr);
                          if (match.isNotEmpty) {
                            selectedLocation = match.first.location;
                          }
                          showSuggestions = false;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFFFFF3E0)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFFE65100)
                                : Colors.grey.shade300,
                            width: isCurrent ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isCurrent
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isCurrent
                                  ? const Color(0xFFE65100)
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                addr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isCurrent
                                      ? const Color(0xFF4E342E)
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text(
                        'Simpan Alamat Utama',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      onPressed: () {
                        if (addressController.text.trim().isNotEmpty) {
                          userProvider.setMainAddress(
                            addressController.text.trim(),
                            location: selectedLocation,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Alamat utama pengiriman berhasil diperbarui!'),
                              backgroundColor: Color(0xFF4E342E),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
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

  void _openRiwayatTransaksi(BuildContext context) {
    final orderData = Provider.of<OrderProvider>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Riwayat Transaksi')),
          body: orderData.orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('Belum ada riwayat transaksi',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('Pesanan Anda akan muncul di sini',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderData.orders.length,
                  itemBuilder: (ctx, i) {
                    final order = orderData.orders[i];
                    Color statusColor = order.status == 'Selesai'
                        ? Colors.green
                        : order.status == 'Dikirim'
                            ? Colors.blue
                            : const Color(0xFFE65100);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(order.id,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    order.status,
                                    style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${order.products.length} item • Rp ${order.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    order.address,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tanggal: ${order.dateTime.day}/${order.dateTime.month}/${order.dateTime.year} - ${order.dateTime.hour.toString().padLeft(2, '0')}:${order.dateTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _openMenuFavorit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Menu Favorit')),
          body: Consumer<MenuProvider>(
            builder: (ctx, menuData, _) {
              final favorites = menuData.favoriteItems;
              if (favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada menu favorit',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4E342E)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tekan ikon hati ❤️ pada katalog\nuntuk menyimpan menu favorit Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favorites.length,
                itemBuilder: (ctx, i) {
                  final menu = favorites[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => DetailScreen(menuId: menu.id)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: buildMenuImage(
                                imageUrl: menu.imageUrl,
                                menuId: menu.id,
                                name: menu.name,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(menu.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(
                                    menu.description,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Rp ${menu.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        color: Color(0xFFE65100),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite,
                                  color: Colors.red),
                              tooltip: 'Hapus dari favorit',
                              onPressed: () {
                                menuData.toggleFavorite(menu.id);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${menu.name} dihapus dari Favorit'),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: const Color(0xFF4E342E),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _openPusatBantuan(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'q': 'Bagaimana cara memesan makanan?',
        'a':
            'Pilih menu yang Anda inginkan dari halaman Beranda, tekan tombol "Add to Cart", lalu buka keranjang dan isi alamat pengiriman, kemudian tekan Checkout.',
      },
      {
        'q': 'Berapa lama waktu pengiriman?',
        'a':
            'Estimasi pengiriman adalah 30–60 menit tergantung jarak dan kondisi lalu lintas di Kota Malang.',
      },
      {
        'q': 'Bagaimana cara melacak pesanan saya?',
        'a':
            'Setelah checkout, status pesanan dapat dipantau melalui halaman Order Tracking (ikon struk di pojok kanan atas halaman Beranda).',
      },
      {
        'q': 'Metode pembayaran apa saja yang tersedia?',
        'a':
            'Saat ini kami mendukung pembayaran tunai (Cash on Delivery / COD) kepada kurir saat pesanan tiba.',
      },
      {
        'q': 'Apakah ada biaya pengiriman?',
        'a':
            'Biaya pengiriman gratis untuk seluruh wilayah Kota Malang. Kami senang melayani Anda!',
      },
      {
        'q': 'Bagaimana jika pesanan saya salah atau tidak sesuai?',
        'a':
            'Segera hubungi kami melalui tombol Hubungi Kami di bawah. Tim kami siap membantu menyelesaikan masalah Anda.',
      },
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Pusat Bantuan')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Banner
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE65100), Color(0xFF4E342E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.support_agent, color: Colors.white, size: 36),
                    SizedBox(height: 10),
                    Text('Ada yang bisa kami bantu?',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                        'Temukan jawaban dari pertanyaan umum di bawah ini.',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const Text('Pertanyaan Umum (FAQ)',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4E342E))),
              const SizedBox(height: 12),
              ...faqs.map((faq) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      iconColor: const Color(0xFFE65100),
                      collapsedIconColor: Colors.grey,
                      title: Text(faq['q']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(faq['a']!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.5)),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              Builder(builder: (ctx) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFE65100)
                          .withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Masih butuh bantuan?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF4E342E))),
                    const SizedBox(height: 8),
                    const Text(
                        'Tim kami siap membantu Anda setiap hari pukul 08.00 – 22.00 WIB.',
                        style:
                            TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Menghubungi tim dukungan...'),
                              backgroundColor: Color(0xFF4E342E),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Hubungi Kami',
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _openTentangAplikasi(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE65100), Color(0xFF4E342E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.soup_kitchen, color: Colors.white, size: 52),
                  SizedBox(height: 8),
                  Text('Kuliner Lokal',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  Text('v1.0.0',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _aboutRow(
                      Icons.info_outline, 'Versi Aplikasi', '1.0.0 (Build 1)'),
                  const Divider(height: 20),
                  _aboutRow(Icons.group_outlined, 'Dikembangkan oleh',
                      'Tim Kelompok Teori'),
                  const Divider(height: 20),
                  _aboutRow(Icons.location_city_outlined, 'Platform',
                      'Flutter – Android & iOS'),
                  const Divider(height: 20),
                  _aboutRow(Icons.restaurant_menu_outlined, 'Fokus',
                      'Kuliner Lokal Kota Malang'),
                  const Divider(height: 20),
                  _aboutRow(Icons.copyright_outlined, 'Hak Cipta',
                      '© 2026 Kuliner Lokal'),
                  const SizedBox(height: 16),
                  const Text(
                    'Aplikasi ini dibuat sebagai proyek tugas kelompok untuk memperkenalkan dan mempermudah akses terhadap kuliner lokal khas Kota Malang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100))),
          ),
        ],
      ),
    );
  }

  static Widget _aboutRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE65100)),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4E342E))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Consumer<UserProvider>(
              builder: (context, userProvider, _) => Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE65100),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFF4E342E),
                        child: Text(
                          userProvider.name.isNotEmpty
                              ? userProvider.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            userProvider.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4E342E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
                          tooltip: 'Ubah Nama',
                          onPressed: () => _editUserNameDialog(context, userProvider),
                        ),
                      ],
                    ),
                    Text(
                      userProvider.email,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Consumer<UserProvider>(
                    builder: (ctx, userProv, _) => ListTile(
                      leading: const Icon(Icons.location_on, color: Color(0xFFE65100)),
                      title: const Text(
                        'Alamat Utama Pengiriman',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 3),
                          Text(
                            userProv.mainAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => openGoogleMaps(
                              address: userProv.mainAddress,
                              latitude: userProv.mainLocation.latitude,
                              longitude: userProv.mainLocation.longitude,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map, size: 14, color: Colors.redAccent),
                                SizedBox(width: 4),
                                Text(
                                  'Buka di Google Maps',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.edit_location_alt, color: Color(0xFFE65100)),
                      onTap: () => _openAlamatPengiriman(context),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history,
                        color: Color(0xFFE65100)),
                    title: const Text('Riwayat Transaksi'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openRiwayatTransaksi(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.favorite_border,
                        color: Color(0xFFE65100)),
                    title: const Text('Menu Favorit'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openMenuFavorit(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline,
                        color: Color(0xFFE65100)),
                    title: const Text('Pusat Bantuan'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openPusatBantuan(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline,
                        color: Color(0xFFE65100)),
                    title: const Text('Tentang Aplikasi'),
                    subtitle: const Text('Kuliner Lokal v1.0.0'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openTentangAplikasi(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Keluar dari Akun'),
                      content: const Text(
                          'Apakah Anda yakin ingin keluar dari akun ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Provider.of<UserProvider>(context, listen: false).logout();
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LoginScreen()),
                            );
                          },
                          child: const Text('Keluar',
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Keluar dari Akun',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editUserNameDialog(BuildContext context, UserProvider userProvider) {
    final editController = TextEditingController(text: userProvider.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ubah Nama Pengguna'),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nama Lengkap',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                userProvider.updateName(editController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nama pengguna berhasil diperbarui!'),
                    backgroundColor: Color(0xFF4E342E),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
