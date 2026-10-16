import 'package:flutter/material.dart';

Widget buildFoodIllustration(String menuId, String name, {double? width, double? height}) {
  Color primaryColor;
  Color secondaryColor;
  IconData foodIcon;
  String emoji;
  String subtitle;

  if (menuId == 'm1' || name.contains('Bakso')) {
    primaryColor = const Color(0xFFD84315);
    secondaryColor = const Color(0xFFBF360C);
    foodIcon = Icons.rice_bowl;
    emoji = '🍲';
    subtitle = 'Bakso • Tahu • Siomay';
  } else if (menuId == 'm2' || name.contains('Rawon')) {
    primaryColor = const Color(0xFF3E2723);
    secondaryColor = const Color(0xFF1B0000);
    foodIcon = Icons.soup_kitchen;
    emoji = '🥩';
    subtitle = 'Kuah Kluwek • Daging Sapi';
  } else if (menuId == 'm3' || name.contains('Pecel')) {
    primaryColor = const Color(0xFF33691E);
    secondaryColor = const Color(0xFF1B5E20);
    foodIcon = Icons.eco;
    emoji = '🥗';
    subtitle = 'Sayur Segar • Bumbu Kacang';
  } else if (menuId == 'm4' || name.contains('Soto')) {
    primaryColor = const Color(0xFFF57F17);
    secondaryColor = const Color(0xFFE65100);
    foodIcon = Icons.ramen_dining;
    emoji = '🍜';
    subtitle = 'Soto Ayam • Koya • Telur';
  } else {
    primaryColor = const Color(0xFF4E342E);
    secondaryColor = const Color(0xFF3E2723);
    foodIcon = Icons.fastfood;
    emoji = '🍱';
    subtitle = 'Kuliner Nusantara';
  }

  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: -15,
          bottom: -15,
          child: Icon(foodIcon, size: 90, color: Colors.white.withValues(alpha: 0.2)),
        ),
        Positioned(
          left: -15,
          top: -15,
          child: Icon(Icons.star_outline, size: 70, color: Colors.white.withValues(alpha: 0.15)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(1, 1))],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildMenuImage({
  required String imageUrl,
  required String menuId,
  required String name,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  if (imageUrl.isEmpty) {
    return buildFoodIllustration(menuId, name, width: width, height: height);
  }

  return Image.network(
    imageUrl,
    width: width,
    height: height,
    fit: fit,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Container(
        width: width,
        height: height,
        color: const Color(0xFFEFEBE9),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE65100)),
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      debugPrint('Error loading network image ($imageUrl): $error');
      return buildFoodIllustration(menuId, name, width: width, height: height);
    },
  );
}
