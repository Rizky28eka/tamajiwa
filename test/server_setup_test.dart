import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamajiwa/constants/api_config.dart';
import 'package:tamajiwa/services/server_check_service.dart';
import 'package:tamajiwa/theme/app_theme.dart';
import 'package:tamajiwa/views/server_setup_view.dart';

void main() {
  group('ApiConfig.normalize', () {
    test('menambah skema, /api, dan membuang spasi serta garis miring akhir', () {
      expect(ApiConfig.normalize('  api.contoh.id  '), 'https://api.contoh.id/api');
      expect(ApiConfig.normalize('https://api.contoh.id/'), 'https://api.contoh.id/api');
      expect(ApiConfig.normalize('https://api.contoh.id/api/'), 'https://api.contoh.id/api');
      expect(ApiConfig.normalize('https://contoh.id/tamajiwa/api'), 'https://contoh.id/tamajiwa/api');
    });

    test('alamat lokal dan IP memakai http, port dipertahankan', () {
      expect(ApiConfig.normalize('192.168.1.5:8000'), 'http://192.168.1.5:8000/api');
      expect(ApiConfig.normalize('localhost:8000'), 'http://localhost:8000/api');
      expect(ApiConfig.normalize('server.local'), 'http://server.local/api');
      expect(ApiConfig.normalize('https://10.0.0.2:8443/api'), 'https://10.0.0.2:8443/api');
    });

    test('menolak input tidak valid', () {
      expect(ApiConfig.normalize(''), isNull);
      expect(ApiConfig.normalize('   '), isNull);
      expect(ApiConfig.normalize('ftp://x.id/api'), isNull);
      expect(ApiConfig.normalize('https://user:pw@x.id/api'), isNull);
      expect(ApiConfig.normalize('https://x.id/api?token=1'), isNull);
      expect(ApiConfig.normalize('https://x.id/a b'), isNull);
      expect(ApiConfig.normalize('https://'), isNull);
    });
  });

  group('ApiConfig simpan/muat', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await ApiConfig.reset();
    });

    test('alamat tersimpan diutamakan dan bertahan setelah dimuat ulang', () async {
      expect(ApiConfig.isConfigured, isFalse);
      expect(await ApiConfig.save('api.contoh.id'), 'https://api.contoh.id/api');
      expect(ApiConfig.isConfigured, isTrue);
      expect(ApiConfig.currentBaseUrl, 'https://api.contoh.id/api');

      await ApiConfig.load(); // seperti membuka aplikasi lagi
      expect(ApiConfig.currentBaseUrl, 'https://api.contoh.id/api');
    });

    test('input tidak valid tidak menimpa alamat yang ada', () async {
      await ApiConfig.save('api.contoh.id');
      expect(await ApiConfig.save('ftp://salah'), isNull);
      expect(ApiConfig.currentBaseUrl, 'https://api.contoh.id/api');
    });

    test('reset kembali ke bawaan', () async {
      await ApiConfig.save('api.contoh.id');
      await ApiConfig.reset();
      expect(ApiConfig.isConfigured, isFalse);
      expect(ApiConfig.currentBaseUrl, anyOf('http://127.0.0.1:8000/api', 'http://10.0.2.2:8000/api'));
    });

    test('nilai rusak di penyimpanan diabaikan, tidak membuat aplikasi gagal', () async {
      SharedPreferences.setMockInitialValues({'api_base_url': 'ftp://rusak'});
      await ApiConfig.load();
      expect(ApiConfig.isConfigured, isFalse);
    });
  });

  group('ServerCheckService', () {
    http.Client reply(int code, String body) =>
        MockClient((_) async => http.Response(body, code));

    test('ok bila /health-check menjawab status OK', () async {
      final r = await ServerCheckService.check('https://x.id/api',
          client: MockClient((req) async {
        expect(req.url.toString(), 'https://x.id/api/health-check');
        return http.Response('{"status":"OK"}', 200);
      }));
      expect(r.ok, isTrue);
    });

    test('bukan Tamajiwa bila 200 tetapi isinya lain', () async {
      final r = await ServerCheckService.check('https://x.id/api',
          client: reply(200, '<html>hi</html>'));
      expect(r.status, ServerCheckStatus.notTamajiwa);
    });

    test('httpError membawa kode status', () async {
      final r = await ServerCheckService.check('https://x.id/api',
          client: reply(404, 'nope'));
      expect(r.status, ServerCheckStatus.httpError);
      expect(r.statusCode, 404);
    });

    test('unreachable bila koneksi gagal atau timeout', () async {
      final fail = await ServerCheckService.check('https://x.id/api',
          client: MockClient((_) async => throw Exception('no route')));
      expect(fail.status, ServerCheckStatus.unreachable);

      final slow = await ServerCheckService.check('https://x.id/api',
          timeout: const Duration(milliseconds: 20),
          client: MockClient((_) => Completer<http.Response>().future));
      expect(slow.status, ServerCheckStatus.unreachable);
    });
  });

  group('ServerSetupView', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await ApiConfig.reset();
    });
    tearDown(() => ServerCheckService.clientOverride = null);

    Future<void> pumpView(WidgetTester t) async {
      t.view.physicalSize = const Size(390, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: const ServerSetupView(),
      ));
    }

    FilledButton saveButton(WidgetTester t) =>
        t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Simpan'));

    testWidgets('Simpan baru aktif setelah tes koneksi berhasil', (t) async {
      ServerCheckService.clientOverride =
          () => MockClient((_) async => http.Response('{"status":"OK"}', 200));
      await pumpView(t);

      expect(saveButton(t).onPressed, isNull);

      await t.enterText(find.byType(TextField), 'api.contoh.id');
      await t.pump();
      expect(saveButton(t).onPressed, isNull, reason: 'belum dites');

      await t.tap(find.text('Tes koneksi'));
      await t.pumpAndSettle();
      expect(find.text('Terhubung ke server Tamajiwa.'), findsOneWidget);
      expect(saveButton(t).onPressed, isNotNull);

      // Mengubah alamat membatalkan hasil tes sebelumnya.
      await t.enterText(find.byType(TextField), 'lain.contoh.id');
      await t.pump();
      expect(saveButton(t).onPressed, isNull);

      await t.tap(find.text('Simpan'));
      await t.pump();
      expect(ApiConfig.isConfigured, isFalse, reason: 'tombol nonaktif, tidak menyimpan');
    });

    testWidgets('gagal tes menampilkan pesan dan menawarkan simpan tanpa tes', (t) async {
      ServerCheckService.clientOverride =
          () => MockClient((_) async => throw Exception('down'));
      await pumpView(t);

      await t.enterText(find.byType(TextField), 'api.contoh.id');
      await t.pump();
      await t.tap(find.text('Tes koneksi'));
      await t.pumpAndSettle();

      expect(find.textContaining('tidak dapat dijangkau'), findsOneWidget);
      expect(saveButton(t).onPressed, isNull);
      expect(find.text('Simpan tanpa tes koneksi'), findsOneWidget);
    });

    testWidgets('alamat http menampilkan peringatan; input salah menampilkan galat', (t) async {
      await pumpView(t);

      await t.enterText(find.byType(TextField), '192.168.1.5:8000');
      await t.pump();
      expect(find.textContaining('tidak terenkripsi'), findsOneWidget);

      await t.enterText(find.byType(TextField), 'ftp://salah');
      await t.pump();
      expect(find.text('Alamat tidak valid'), findsOneWidget);
    });
  });
}
