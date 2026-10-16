import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/food_image_widget.dart';

class DetailScreen extends StatelessWidget {
  final String menuId;
  const DetailScreen({super.key, required this.menuId});

  @override
  Widget build(BuildContext context) {
    final loadedMenu = Provider.of<MenuProvider>(context, listen: false)
        .items
        .firstWhere((menu) => menu.id == menuId);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Menu')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildMenuImage(
            imageUrl: loadedMenu.imageUrl,
            menuId: loadedMenu.id,
            name: loadedMenu.name,
            height: 300,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            loadedMenu.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
                          ),
                        ),
                        Text(
                          'Rp ${loadedMenu.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Deskripsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      loadedMenu.description,
                      style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          onPressed: () {
            Provider.of<CartProvider>(context, listen: false).addItem(
              loadedMenu.id,
              loadedMenu.price,
              loadedMenu.name,
              loadedMenu.imageUrl,
            );
            Navigator.pop(context);
          },
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Tambah ke Keranjang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
