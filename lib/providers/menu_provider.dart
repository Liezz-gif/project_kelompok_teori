import 'package:flutter/material.dart';
import '../models/menu_model.dart';

class MenuProvider with ChangeNotifier {
  final List<Menu> _items = [
    Menu(
      id: 'm1',
      name: 'Bakso Malang Komplit',
      description: 'Bakso sapi asli dengan tambahan tahu, siomay, dan gorengan renyah khas Malang.',
      price: 20000,
      imageUrl: 'https://asset.kompas.com/crops/LIjgzTN7piXsTTdECd6ycijJTUk=/0x129:1000x796/1200x800/data/photo/2020/03/03/5e5e292daa840.jpg',
    ),
    Menu(
      id: 'm2',
      name: 'Rawon Daging Sapi',
      description: 'Kuah hitam kluwek yang kaya rempah dengan irisan daging sapi empuk, tauge pendek, dan sambal terasi.',
      price: 25000,
      imageUrl: 'https://www.holycowsteak.com/cdn/shop/articles/Thumbnail_bccc9157-1b79-47ed-9300-391dede1d189.webp?v=1748245794',
    ),
    Menu(
      id: 'm3',
      name: 'Pecel Kawi',
      description: 'Sayuran segar dengan siraman bumbu kacang legit khas Jawa Timur.',
      price: 15000,
      imageUrl: 'https://asset.kompas.com/crops/Bl583WdJr0__J2epTtcT-4azxOQ=/60x23:959x622/1200x800/data/photo/2020/11/05/5fa3f16d9c1cf.jpg',
    ),
    Menu(
      id: 'm4',
      name: 'Soto Lombok',
      description: 'Soto ayam kampung khas Malang dengan taburan koya gurih dan kuah kuning yang segar.',
      price: 18000,
      imageUrl: 'https://jalan2.id/wp-content/uploads/2024/05/sotolombok-2-scaled.jpg',
    ),
  ];

  final Set<String> _favoriteIds = {};

  List<Menu> get items => [..._items];

  List<Menu> get favoriteItems =>
      _items.where((item) => _favoriteIds.contains(item.id)).toList();

  bool isFavorite(String menuId) => _favoriteIds.contains(menuId);

  void toggleFavorite(String menuId) {
    if (_favoriteIds.contains(menuId)) {
      _favoriteIds.remove(menuId);
    } else {
      _favoriteIds.add(menuId);
    }
    notifyListeners();
  }
}
