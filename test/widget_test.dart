import 'package:flutter_test/flutter_test.dart';
import 'package:project_kelompok_teori/main.dart';

void main() {
  testWidgets('KulinerLokalApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KulinerLokalApp());

    // Verify that Login Screen is loaded.
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Welcome, Kuliner Lokal'), findsOneWidget);
  });
}
