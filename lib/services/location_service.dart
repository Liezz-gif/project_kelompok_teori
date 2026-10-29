import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class AddressLocationItem {
  final String title;
  final String subtitle;
  final String fullAddress;
  final LatLng location;
  final bool isOnline;
  final List<String> keywords;

  const AddressLocationItem({
    required this.title,
    required this.subtitle,
    required this.fullAddress,
    required this.location,
    this.isOnline = false,
    this.keywords = const [],
  });
}

class LocationService {
  /// Pusat Kota Malang (Alun-Alun) sebagai fallback
  static const LatLng malangDefaultCenter = LatLng(-7.9826, 112.6308);

  /// Database komprehensif lokasi, asrama, kampus, jalan, dan fasilitas di Malang
  static const List<AddressLocationItem> curatedLocations = [
    // --- ASRAMA MAHASISWA ---
    AddressLocationItem(
      title: 'Asrama Putra ISBA Malang',
      subtitle: 'Jl. Terusan Margojoyo Jetis, Mulyoagung, Dau, Kab. Malang',
      fullAddress: 'Asrama Putra ISBA Malang, Jl. Terusan Margojoyo Jetis, Dau, Malang',
      location: LatLng(-7.921698, 112.585910),
      keywords: [
        'isba',
        'isba putra',
        'asrama isba',
        'asrama putra isba',
        'asrama putra isba malang',
        'asrama bangka',
        'margojoyo',
        'terusan margojoyo',
        'dau',
        'jetis',
      ],
    ),
    AddressLocationItem(
      title: 'Asrama Putri ISBA Malang',
      subtitle: 'Jl. Kerto Raharjo No. 12, Ketawanggede, Lowokwaru, Malang',
      fullAddress: 'Asrama Putri ISBA Malang, Jl. Kerto Raharjo No. 12, Lowokwaru, Malang',
      location: LatLng(-7.948500, 112.607200),
      keywords: [
        'isba',
        'isba putri',
        'asrama isba',
        'asrama putri isba',
        'asrama putri isba malang',
        'asrama bangka putri',
        'kerto raharjo',
        'ketawanggede',
      ],
    ),
    AddressLocationItem(
      title: 'Asrama Mahasiswa Papua Malang',
      subtitle: 'Jl. Kalpataru No. 47, Jatimulyo, Lowokwaru, Malang',
      fullAddress: 'Asrama Mahasiswa Papua, Jl. Kalpataru No. 47, Lowokwaru, Malang',
      location: LatLng(-7.947200, 112.624100),
      keywords: ['asrama papua', 'papua', 'kalpataru', 'jatimulyo'],
    ),
    AddressLocationItem(
      title: 'Asrama Mahasiswa Aceh (Pocut Baren)',
      subtitle: 'Jl. Bunga Mondokaki No. 1, Jatimulyo, Lowokwaru, Malang',
      fullAddress: 'Asrama Mahasiswa Aceh, Jl. Bunga Mondokaki No. 1, Lowokwaru, Malang',
      location: LatLng(-7.946300, 112.620200),
      keywords: ['asrama aceh', 'aceh', 'pocut baren', 'mondokaki'],
    ),
    AddressLocationItem(
      title: 'Asrama Mahasiswa Kalbar (Rahadi Usman)',
      subtitle: 'Jl. Bendungan Sigura-gura Barat No. 25, Lowokwaru, Malang',
      fullAddress: 'Asrama Mahasiswa Kalbar, Jl. Bendungan Sigura-gura Barat, Malang',
      location: LatLng(-7.958200, 112.609400),
      keywords: ['asrama kalbar', 'kalimantan', 'sigura gura', 'rahadi usman'],
    ),
    AddressLocationItem(
      title: 'Asrama Mahasiswa Riau',
      subtitle: 'Jl. Rembulan No. 15, Lowokwaru, Malang',
      fullAddress: 'Asrama Mahasiswa Riau, Jl. Rembulan No. 15, Lowokwaru, Malang',
      location: LatLng(-7.944800, 112.617300),
      keywords: ['asrama riau', 'riau', 'rembulan'],
    ),

    // --- KAMPUS & PERGURUAN TINGGI ---
    AddressLocationItem(
      title: 'Universitas Brawijaya (UB)',
      subtitle: 'Jl. Veteran No. 8, Ketawanggede, Lowokwaru, Malang',
      fullAddress: 'Universitas Brawijaya (UB), Jl. Veteran No. 8, Lowokwaru, Malang',
      location: LatLng(-7.952500, 112.614200),
      keywords: ['ub', 'brawijaya', 'universitas brawijaya', 'veteran'],
    ),
    AddressLocationItem(
      title: 'Universitas Negeri Malang (UM)',
      subtitle: 'Jl. Semarang No. 5, Sumbersari, Lowokwaru, Malang',
      fullAddress: 'Universitas Negeri Malang (UM), Jl. Semarang No. 5, Malang',
      location: LatLng(-7.978400, 112.621900),
      keywords: ['um', 'negeri malang', 'semarang', 'sumbersari'],
    ),
    AddressLocationItem(
      title: 'UMM Kampus 3 (Muhammadiyah)',
      subtitle: 'Jl. Raya Tlogomas No. 246, Babatan, Tegalgondo, Dau, Malang',
      fullAddress: 'Universitas Muhammadiyah Malang (UMM) Kampus 3, Jl. Raya Tlogomas, Malang',
      location: LatLng(-7.920800, 112.597600),
      keywords: ['umm', 'muhammadiyah', 'tlogomas', 'umm kampus 3'],
    ),
    AddressLocationItem(
      title: 'Politeknik Negeri Malang (Polinema)',
      subtitle: 'Jl. Soekarno Hatta No. 9, Jatimulyo, Lowokwaru, Malang',
      fullAddress: 'Polinema, Jl. Soekarno Hatta No. 9, Lowokwaru, Malang',
      location: LatLng(-7.946800, 112.615800),
      keywords: ['polinema', 'poltek', 'soekarno hatta', 'suhat'],
    ),
    AddressLocationItem(
      title: 'UIN Maulana Malik Ibrahim Malang',
      subtitle: 'Jl. Gajayana No. 50, Dinoyo, Lowokwaru, Malang',
      fullAddress: 'UIN Maliki Malang, Jl. Gajayana No. 50, Lowokwaru, Malang',
      location: LatLng(-7.952300, 112.607800),
      keywords: ['uin', 'uin malang', 'maliki', 'gajayana', 'dinoyo'],
    ),
    AddressLocationItem(
      title: 'Universitas Islam Malang (Unisma)',
      subtitle: 'Jl. Mayjen Haryono No. 193, Dinoyo, Lowokwaru, Malang',
      fullAddress: 'Unisma, Jl. Mayjen Haryono No. 193, Lowokwaru, Malang',
      location: LatLng(-7.939200, 112.604200),
      keywords: ['unisma', 'islam malang', 'mt haryono', 'dinoyo'],
    ),
    AddressLocationItem(
      title: 'ITN Malang Kampus 1',
      subtitle: 'Jl. Bendungan Sigura-gura No. 2, Sumbersari, Malang',
      fullAddress: 'ITN Malang Kampus 1, Jl. Bendungan Sigura-gura No. 2, Malang',
      location: LatLng(-7.958900, 112.612100),
      keywords: ['itn', 'sigura-gura', 'sumbersari'],
    ),
    AddressLocationItem(
      title: 'BINUS University Malang',
      subtitle: 'Araya Mansion No. 8-22, Genitri, Pakis, Malang',
      fullAddress: 'BINUS University Malang, Araya Mansion, Pakis, Malang',
      location: LatLng(-7.941900, 112.670800),
      keywords: ['binus', 'araya', 'pakis'],
    ),
    AddressLocationItem(
      title: 'Universitas Merdeka (Unmer) Malang',
      subtitle: 'Jl. Terusan Dieng No. 62, Pisang Candi, Sukun, Malang',
      fullAddress: 'Unmer Malang, Jl. Terusan Dieng No. 62, Sukun, Malang',
      location: LatLng(-7.976500, 112.607500),
      keywords: ['unmer', 'dieng', 'sukun'],
    ),

    // --- JALAN-JALAN UTAMA & PUSAT KOST MALANG ---
    AddressLocationItem(
      title: 'Jl. Terusan Margojoyo',
      subtitle: 'Jetis, Mulyoagung, Kec. Dau, Kab. Malang',
      fullAddress: 'Jl. Terusan Margojoyo, Mulyoagung, Dau, Malang',
      location: LatLng(-7.921698, 112.585910),
      keywords: ['margojoyo', 'terusan margojoyo', 'dau', 'jetis', 'isba'],
    ),
    AddressLocationItem(
      title: 'Jl. Soekarno Hatta (Suhat)',
      subtitle: 'Jatimulyo, Kec. Lowokwaru, Kota Malang',
      fullAddress: 'Jl. Soekarno Hatta, Lowokwaru, Kota Malang',
      location: LatLng(-7.944200, 112.616700),
      keywords: ['suhat', 'soekarno hatta', 'lowokwaru'],
    ),
    AddressLocationItem(
      title: 'Jl. Veteran No. 8',
      subtitle: 'Lowokwaru, Kota Malang',
      fullAddress: 'Jl. Veteran No. 8, Lowokwaru, Kota Malang',
      location: LatLng(-7.952300, 112.614200),
      keywords: ['veteran', 'jl veteran', 'matos'],
    ),
    AddressLocationItem(
      title: 'Jl. Bendungan Sigura-gura',
      subtitle: 'Sumbersari, Kec. Lowokwaru, Kota Malang',
      fullAddress: 'Jl. Bendungan Sigura-gura, Sumbersari, Lowokwaru, Malang',
      location: LatLng(-7.959800, 112.610500),
      keywords: ['sigura gura', 'bendungan sigura gura', 'sumbersari'],
    ),
    AddressLocationItem(
      title: 'Jl. Bendungan Sutami',
      subtitle: 'Sumbersari, Kec. Lowokwaru, Kota Malang',
      fullAddress: 'Jl. Bendungan Sutami, Sumbersari, Lowokwaru, Malang',
      location: LatLng(-7.957000, 112.614300),
      keywords: ['sutami', 'bendungan sutami', 'sumbersari'],
    ),
    AddressLocationItem(
      title: 'Jl. MT Haryono',
      subtitle: 'Dinoyo, Kec. Lowokwaru, Kota Malang',
      fullAddress: 'Jl. MT Haryono, Dinoyo, Lowokwaru, Malang',
      location: LatLng(-7.943000, 112.607800),
      keywords: ['mt haryono', 'dinoyo', 'haryono'],
    ),
    AddressLocationItem(
      title: 'Jl. Kerto Raharjo',
      subtitle: 'Ketawanggede, Kec. Lowokwaru, Kota Malang',
      fullAddress: 'Jl. Kerto Raharjo, Ketawanggede, Lowokwaru, Malang',
      location: LatLng(-7.948500, 112.607200),
      keywords: ['kerto raharjo', 'kerto', 'ketawanggede'],
    ),
    AddressLocationItem(
      title: 'Jl. Gajayana',
      subtitle: 'Ketawanggede, Kec. Lowokwaru, Kota Malang',
      fullAddress: 'Jl. Gajayana, Lowokwaru, Kota Malang',
      location: LatLng(-7.951500, 112.609100),
      keywords: ['gajayana', 'ketawanggede'],
    ),
    AddressLocationItem(
      title: 'Jl. Dinoyo No. 45',
      subtitle: 'Lowokwaru, Kota Malang',
      fullAddress: 'Jl. Dinoyo No. 45, Lowokwaru, Malang',
      location: LatLng(-7.946600, 112.607500),
      keywords: ['dinoyo', 'jl dinoyo'],
    ),
    AddressLocationItem(
      title: 'Jl. Borobudur No. 18',
      subtitle: 'Mojolangu, Kota Malang',
      fullAddress: 'Jl. Borobudur No. 18, Blimbing, Malang',
      location: LatLng(-7.937900, 112.633800),
      keywords: ['borobudur', 'blimbing'],
    ),
    AddressLocationItem(
      title: 'Jl. Kawi No. 24',
      subtitle: 'Kauman, Kec. Klojen, Kota Malang',
      fullAddress: 'Jl. Kawi No. 24, Kauman, Klojen, Malang',
      location: LatLng(-7.980800, 112.624100),
      keywords: ['kawi', 'kauman', 'klojen'],
    ),
    AddressLocationItem(
      title: 'Jl. Besar Ijen No. 10',
      subtitle: 'Gading Kasri, Kec. Klojen, Kota Malang',
      fullAddress: 'Jl. Besar Ijen No. 10, Gading Kasri, Malang',
      location: LatLng(-7.969800, 112.621500),
      keywords: ['ijen', 'besar ijen', 'klojen'],
    ),
    AddressLocationItem(
      title: 'Jl. Danau Toba',
      subtitle: 'Sawojajar, Kec. Kedungkandang, Kota Malang',
      fullAddress: 'Jl. Danau Toba, Sawojajar, Kedungkandang, Malang',
      location: LatLng(-7.973400, 112.658200),
      keywords: ['danau toba', 'sawojajar'],
    ),
    AddressLocationItem(
      title: 'Jl. Mayjend Panjaitan No. 88',
      subtitle: 'Penanggungan, Kec. Klojen, Kota Malang',
      fullAddress: 'Jl. Mayjend Panjaitan No. 88, Penanggungan, Malang',
      location: LatLng(-7.968100, 112.631000),
      keywords: ['panjaitan', 'betek', 'penanggungan'],
    ),

    // --- MALL, STASIUN, FASILITAS UMUM ---
    AddressLocationItem(
      title: 'Malang Town Square (Matos)',
      subtitle: 'Jl. Veteran No. 2, Penanggungan, Klojen, Malang',
      fullAddress: 'Malang Town Square (Matos), Jl. Veteran, Malang',
      location: LatLng(-7.956600, 112.618600),
      keywords: ['matos', 'malang town square', 'veteran mall'],
    ),
    AddressLocationItem(
      title: 'Olympic Garden Mall (MOG)',
      subtitle: 'Jl. Tenes No. 10, Kauman, Klojen, Malang',
      fullAddress: 'Olympic Garden Mall (MOG), Jl. Tenes, Malang',
      location: LatLng(-7.975600, 112.624900),
      keywords: ['mog', 'olympic garden mall', 'tenes'],
    ),
    AddressLocationItem(
      title: 'Alun-Alun Kota Malang',
      subtitle: 'Jl. Merdeka Selatan, Kiduldalem, Klojen, Malang',
      fullAddress: 'Alun-Alun Kota Malang, Jl. Merdeka Selatan, Malang',
      location: LatLng(-7.982600, 112.630800),
      keywords: ['alun alun', 'alun-alun', 'merdeka selatan', 'klojen'],
    ),
    AddressLocationItem(
      title: 'Alun-Alun Tugu Malang',
      subtitle: 'Jl. Tugu, Kiduldalem, Klojen, Malang',
      fullAddress: 'Alun-Alun Tugu Malang, Jl. Tugu, Klojen, Malang',
      location: LatLng(-7.977400, 112.634100),
      keywords: ['tugu', 'alun alun tugu', 'balai kota'],
    ),
    AddressLocationItem(
      title: 'Stasiun Malang Kotabaru',
      subtitle: 'Jl. Trunojoyo No. 10, Klojen, Kota Malang',
      fullAddress: 'Stasiun Malang Kotabaru, Jl. Trunojoyo, Malang',
      location: LatLng(-7.977300, 112.637500),
      keywords: ['stasiun', 'kotabaru', 'stasiun malang', 'trunojoyo'],
    ),
    AddressLocationItem(
      title: 'Pasar Besar Malang',
      subtitle: 'Jl. Pasar Besar, Sukoharjo, Klojen, Malang',
      fullAddress: 'Pasar Besar Malang, Jl. Pasar Besar, Malang',
      location: LatLng(-7.988200, 112.631500),
      keywords: ['pasar besar', 'pasar', 'sukoharjo'],
    ),
    AddressLocationItem(
      title: 'RSUD Dr. Saiful Anwar (RSSA)',
      subtitle: 'Jl. Jaksa Agung Suprapto No. 2, Klojen, Malang',
      fullAddress: 'RSUD Dr. Saiful Anwar (RSSA), Jl. Jaksa Agung Suprapto, Malang',
      location: LatLng(-7.972300, 112.631800),
      keywords: ['rssa', 'saiful anwar', 'rumah sakit', 'jaksa agung suprapto'],
    ),
    AddressLocationItem(
      title: 'RS Universitas Brawijaya (RSUB)',
      subtitle: 'Jl. Soekarno Hatta, Jatimulyo, Lowokwaru, Malang',
      fullAddress: 'RS Universitas Brawijaya (RSUB), Jl. Soekarno Hatta, Malang',
      location: LatLng(-7.936500, 112.615200),
      keywords: ['rsub', 'rumah sakit ub', 'suhat'],
    ),
  ];

  /// Cari di database lokal secara instan (minimal 2 karakter query)
  static List<AddressLocationItem> searchLocal(String query) {
    final cleanQuery = query.trim().toLowerCase();
    // Cegah pencarian dengan hanya 1 karakter agar tidak membanjiri hasil
    if (cleanQuery.length < 2) return [];

    final tokens = cleanQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return [];

    final results = <AddressLocationItem>[];

    for (final item in curatedLocations) {
      final t = item.title.toLowerCase();
      final s = item.subtitle.toLowerCase();
      final f = item.fullAddress.toLowerCase();

      bool allMatch = true;
      for (final token in tokens) {
        final inTitle = t.contains(token);
        final inSubtitle = s.contains(token);
        final inFull = f.contains(token);
        final inKeywords = item.keywords.any((k) => k.contains(token) || token.contains(k));

        if (!inTitle && !inSubtitle && !inFull && !inKeywords) {
          allMatch = false;
          break;
        }
      }

      if (allMatch) {
        results.add(item);
      }
    }

    return results;
  }

  /// Cari alamat secara menyeluruh: lokal dulu, lalu online jika query sudah cukup panjang (>= 3 karakter)
  static Future<List<AddressLocationItem>> searchLocations(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) return [];

    final localMatches = searchLocal(cleanQuery);

    // Jika local match sudah ada (>= 2), utamakan hasil lokal agar instan tanpa loading
    if (localMatches.length >= 2 || cleanQuery.length < 3) {
      return localMatches;
    }

    // Cari online via Nominatim hanya jika query >= 3 karakter dan hasil lokal sedikit
    try {
      final encoded = Uri.encodeComponent(cleanQuery);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encoded&format=json&limit=4&countrycodes=id&viewbox=112.50,-7.85,112.75,-8.05&bounded=0',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'KulinerLokalApp/1.0 (delivery@kulinerlokal.id)',
          'Accept-Language': 'id,en',
        },
      ).timeout(const Duration(milliseconds: 2500));

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        final onlineResults = <AddressLocationItem>[];

        for (final item in list) {
          final lat = double.tryParse(item['lat'].toString());
          final lon = double.tryParse(item['lon'].toString());
          final displayName = (item['display_name'] ?? '').toString();
          final name = (item['name'] ?? '').toString();

          if (lat != null && lon != null && displayName.isNotEmpty) {
            final parts = displayName.split(',');
            final mainTitle = name.isNotEmpty ? name : parts.first.trim();
            final subtitle = parts.length > 1
                ? parts.sublist(1, parts.length > 4 ? 4 : parts.length).join(',').trim()
                : displayName;

            onlineResults.add(
              AddressLocationItem(
                title: mainTitle,
                subtitle: subtitle,
                fullAddress: displayName,
                location: LatLng(lat, lon),
                isOnline: true,
              ),
            );
          }
        }

        final combined = [...localMatches];
        for (final online in onlineResults) {
          final isDuplicate = combined.any((existing) =>
              (existing.location.latitude - online.location.latitude).abs() < 0.001 &&
              (existing.location.longitude - online.location.longitude).abs() < 0.001);

          if (!isDuplicate) {
            combined.add(online);
          }
        }

        if (combined.isNotEmpty) return combined;
      }
    } catch (_) {
      // Timeout atau gangguan jaringan, abaikan dan kembalikan hasil lokal
    }

    return localMatches;
  }

  /// Reverse geocoding: Mengubah LatLng dari ketukan peta menjadi teks alamat nyata
  static Future<String?> reverseGeocode(LatLng location) async {
    // 1. Cek apakah dekat dengan lokasi curated yang kita miliki (jarak < 80 meter)
    for (final item in curatedLocations) {
      final dLat = (item.location.latitude - location.latitude).abs();
      final dLng = (item.location.longitude - location.longitude).abs();
      if (dLat < 0.0007 && dLng < 0.0007) {
        return item.fullAddress;
      }
    }

    // 2. Tanya ke OpenStreetMap Nominatim reverse
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${location.latitude}&lon=${location.longitude}&format=json',
      );
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'KulinerLokalApp/1.0 (delivery@kulinerlokal.id)',
          'Accept-Language': 'id,en',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        if (address != null && address is Map) {
          final road = address['road'] ?? address['pedestrian'] ?? address['neighbourhood'] ?? '';
          final suburb = address['suburb'] ?? address['village'] ?? address['hamlet'] ?? '';
          final city = address['city'] ?? address['county'] ?? 'Malang';

          final parts = [road, suburb, city].where((p) => p.toString().isNotEmpty).toList();
          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }

        final displayName = data['display_name'];
        if (displayName != null) {
          final parts = displayName.toString().split(',');
          if (parts.length > 3) {
            return parts.sublist(0, 3).join(',').trim();
          }
          return displayName.toString();
        }
      }
    } catch (_) {}

    return 'Titik Terpilih (${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}), Malang';
  }
}
