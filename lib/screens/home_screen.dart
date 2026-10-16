import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/food_image_widget.dart';
import '../widgets/cart_bottom_bar.dart';
import 'detail_screen.dart';
import 'cart_screen.dart';
import 'tracking_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuData = Provider.of<MenuProvider>(context);
    final menus = menuData.items;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.soup_kitchen),
            SizedBox(width: 8),
            Text('Kuliner Lokal', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TrackingScreen()),
            ),
          ),
          Consumer<CartProvider>(
            builder: (_, cart, ch) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  ),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: const Color(0xFFE65100),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              'Katalog Kuliner',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: menus.length,
              itemBuilder: (ctx, i) => InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailScreen(menuId: menus[i].id)),
                ),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildMenuImage(
                          imageUrl: menus[i].imageUrl,
                          menuId: menus[i].id,
                          name: menus[i].name,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menus[i].name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${menus[i].price.toStringAsFixed(0)}',
                              style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  Provider.of<CartProvider>(context, listen: false).addItem(
                                    menus[i].id,
                                    menus[i].price,
                                    menus[i].name,
                                    menus[i].imageUrl,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${menus[i].name} ditambahkan!', style: const TextStyle(color: Colors.white)),
                                      backgroundColor: const Color(0xFF4E342E),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add_shopping_cart, size: 16),
                                label: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CartBottomBar(),
    );
  }
}
