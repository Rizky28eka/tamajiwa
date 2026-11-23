import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Menyimpan tangkapan layar ke `docs/screenshots/`.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final file = File('docs/screenshots/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
