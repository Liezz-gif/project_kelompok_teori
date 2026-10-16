import 'package:flutter/material.dart';
import '../models/menu_model.dart';

class MenuProvider with ChangeNotifier {
  final List<Menu> _items = [
    Menu(
      id: 'm1',
      name: 'Bakso Malang Komplit',
      description: 'Bakso sapi asli dengan tambahan tahu, siomay, dan gorengan renyah khas Malang.',
      price: 20000,
      imageUrl: 'https://images.unsplash.com/photo-1594998893017-36147cbcae05?w=600&auto=format&fit=crop&q=80',
    ),
    Menu(
      id: 'm2',
      name: 'Rawon Daging Sapi',
      description: 'Kuah hitam kluwek yang kaya rempah dengan irisan daging sapi empuk, tauge pendek, dan sambal terasi.',
      price: 25000,
      imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=600&auto=format&fit=crop&q=80',
    ),
    Menu(
      id: 'm3',
      name: 'Pecel Kawi',
      description: 'Sayuran segar dengan siraman bumbu kacang legit khas Jawa Timur.',
      price: 15000,
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80',
    ),
    Menu(
      id: 'm4',
      name: 'Soto Lombok',
      description: 'Soto ayam kampung khas Malang dengan taburan koya gurih dan kuah kuning yang segar.',
      price: 18000,
      imageUrl: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=600&auto=format&fit=crop&q=80',
    ),
  ];

  List<Menu> get items => [..._items];
}
