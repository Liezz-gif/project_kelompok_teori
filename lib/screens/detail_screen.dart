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
      appBar: AppBar(
        title: const Text('Detail Menu'),
        actions: [
          Consumer<MenuProvider>(
            builder: (ctx, menuProv, _) {
              final isFav = menuProv.isFavorite(loadedMenu.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : Colors.white,
                ),
                tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                onPressed: () {
                  menuProv.toggleFavorite(loadedMenu.id);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav
                            ? '${loadedMenu.name} dihapus dari Favorit'
                            : '${loadedMenu.name} ditambahkan ke Favorit ❤️',
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: const Color(0xFF4E342E),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${loadedMenu.name} ditambahkan ke keranjang!', style: const TextStyle(color: Colors.white)),
                backgroundColor: const Color(0xFF4E342E),
                duration: const Duration(seconds: 1),
              ),
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
