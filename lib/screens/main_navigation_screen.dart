import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'tracking_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    CartScreen(),
    TrackingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: const Color(0xFF4E342E),
          indicatorColor: const Color(0xFFE65100),
          elevation: 8,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.home, color: Colors.white),
              label: 'Katalog',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cart.totalQuantity > 0,
                label: Text('${cart.totalQuantity}'),
                backgroundColor: const Color(0xFFE65100),
                child: const Icon(Icons.shopping_cart_outlined, color: Colors.white70),
              ),
              selectedIcon: Badge(
                isLabelVisible: cart.totalQuantity > 0,
                label: Text('${cart.totalQuantity}'),
                backgroundColor: const Color(0xFFE65100),
                child: const Icon(Icons.shopping_cart, color: Colors.white),
              ),
              label: 'Keranjang',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.receipt_long, color: Colors.white),
              label: 'Pesanan',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.white70),
              selectedIcon: Icon(Icons.person, color: Colors.white),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}