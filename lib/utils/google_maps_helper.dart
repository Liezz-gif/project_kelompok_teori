import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openGoogleMaps(String address) async {
  if (address.trim().isEmpty) return;
  final encodedAddress = Uri.encodeComponent(address);
  final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');

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
