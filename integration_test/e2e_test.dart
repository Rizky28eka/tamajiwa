// Uji menyeluruh sekaligus pengambil tangkapan layar: login lewat UI ke backend lokal
// yang sudah di-seed (`php artisan migrate:fresh --seed`), lalu membuka tiap tab.
//
//   cd backend && php artisan serve
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/e2e_test.dart -d <simulator> --dart-define=ROLE=mahasiswa
//
// Akun demo: mahasiswa1@example.com atau dosen1@example.com, password `password`.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tamajiwa/main.dart' as app;

const _role = String.fromEnvironment('ROLE', defaultValue: 'mahasiswa');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> wait(WidgetTester t, [double seconds = 1.5]) async {
    for (var i = 0; i < (seconds * 10).round(); i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> shot(WidgetTester t, String name, [double seconds = 1.5]) async {
    await wait(t, seconds);
    await binding.takeScreenshot('$_role-$name');
  }

  testWidgets('login and browse as $_role', (t) async {
    app.main();
    await wait(t, 5);
    // Run pertama: layar "Hubungkan ke server" muncul lebih dulu.
    if (find.text('Hubungkan ke server').evaluate().isNotEmpty) {
      await shot(t, 'server-setup', 0.5);
      await t.enterText(find.byType(TextField).first, 'http://127.0.0.1:8000/api');
      await t.pump();
      FocusManager.instance.primaryFocus?.unfocus();
      await wait(t, 1);
      await t.tap(find.text('Tes koneksi'));
      await wait(t, 4);
      await t.tap(find.text('Simpan & lanjut'));
      await wait(t, 3);
    }
    await shot(t, 'login', 0.5);

    final fields = find.byType(TextField);
    expect(fields, findsAtLeastNWidgets(2), reason: 'login form should be visible');
    await t.enterText(fields.at(0), '${_role}1@example.com');
    await t.enterText(fields.at(1), 'password');
    await t.pump();
    FocusManager.instance.primaryFocus?.unfocus(); // tutup keyboard agar tombol tidak tertutup
    await wait(t, 1);
    await t.tap(find.text('Masuk').last);
    await wait(t, 5);
    await shot(t, 'dashboard', 2);

    for (final entry in {
      'tab2': _role == 'dosen' ? Icons.school_outlined : Icons.people_alt_outlined,
      'tab3': Icons.description_outlined,
      'tab4': Icons.person_outline_rounded,
    }.entries) {
      final icon = find.byIcon(entry.value);
      if (icon.evaluate().isEmpty) continue;
      await t.tap(icon.first);
      await shot(t, entry.key, 2.5);
    }
  });
}
