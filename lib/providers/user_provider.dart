import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class UserProvider with ChangeNotifier {
  String _email = 'user@kulinerlokal.com';
  String _name = 'Kuliner Lokal User';
  String _mainAddress = 'Jl. Veteran No. 8, Lowokwaru, Malang';
  LatLng _mainLocation = const LatLng(-7.9523, 112.6142);

  final List<String> _savedAddresses = [
    'Jl. Veteran No. 8, Lowokwaru, Malang',
    'Asrama Putra ISBA Malang, Jl. Terusan Margojoyo Jetis, Dau, Malang',
    'Universitas Brawijaya (UB), Jl. Veteran No. 8, Lowokwaru, Malang',
    'Jl. Soekarno Hatta No. 9, Jatimulyo, Malang',
    'Jl. Kawi No. 24, Kauman, Malang',
  ];

  String get email => _email;
  String get name => _name;
  String get mainAddress => _mainAddress;
  LatLng get mainLocation => _mainLocation;
  List<String> get savedAddresses => [..._savedAddresses];

  void setUser(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return;

    _email = trimmed;

    if (trimmed.contains('@')) {
      final prefix = trimmed.split('@').first;
      final formattedName = prefix
          .replaceAll(RegExp(r'[._\-]'), ' ')
          .split(' ')
          .where((part) => part.isNotEmpty)
          .map((part) => part[0].toUpperCase() + part.substring(1))
          .join(' ');

      _name = formattedName.isNotEmpty ? formattedName : prefix;
    } else {
      _name = trimmed;
    }

    notifyListeners();
  }

  void updateName(String newName) {
    if (newName.trim().isNotEmpty) {
      _name = newName.trim();
      notifyListeners();
    }
  }

  void setMainAddress(String address, {LatLng? location}) {
    final trimmed = address.trim();
    if (trimmed.isNotEmpty) {
      _mainAddress = trimmed;
      if (location != null) {
        _mainLocation = location;
      }
      if (!_savedAddresses.contains(_mainAddress)) {
        _savedAddresses.insert(0, _mainAddress);
      }
      notifyListeners();
    }
  }

  void logout() {
    _email = 'user@kulinerlokal.com';
    _name = 'Kuliner Lokal User';
    notifyListeners();
  }
}
