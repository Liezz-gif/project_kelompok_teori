import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openGoogleMaps({
  String? address,
  double? latitude,
  double? longitude,
}) async {
  Uri googleMapsUrl;
  if (latitude != null && longitude != null) {
    googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
  } else if (address != null && address.trim().isNotEmpty) {
    final encodedAddress = Uri.encodeComponent(address.trim());
    googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );
  } else {
    return;
  }

  try {
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
    }
  } catch (e) {
    debugPrint('Error launching Google Maps: $e');
  }
}
