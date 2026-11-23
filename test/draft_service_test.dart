import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamajiwa/services/draft_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('menyimpan lalu memulihkan nilai, termasuk DateTime bersarang', () async {
    final when = DateTime(2026, 11, 23, 9, 30);
    await DraftService.save('pengkajian', 7, {
      'nama': 'Budi',
      'umur': 30,
      'tanggal': when,
      'keluhan': ['pusing', 'mual'],
      'riwayat': {'tgl': when, 'ada': true},
    });

    final draft = await DraftService.load('pengkajian', 7);
    expect(draft, isNotNull);
    expect(draft!.values['nama'], 'Budi');
    expect(draft.values['umur'], 30);
    expect(draft.values['tanggal'], when);
    expect(draft.values['keluhan'], ['pusing', 'mual']);
    expect((draft.values['riwayat'] as Map)['tgl'], when);
    expect(draft.savedAt, isNotNull);
  });

  test('nilai yang tidak bisa diserialisasi dibuang, bukan membuat gagal', () async {
    await DraftService.save('sap', 1, {'ok': 'ya', 'objek': Object()});
    final draft = await DraftService.load('sap', 1);
    expect(draft!.values, {'ok': 'ya'});
  });

  test('draf terpisah per jenis formulir dan pasien', () async {
    await DraftService.save('sap', 1, {'a': 1});
    expect(await DraftService.load('sap', 2), isNull);
    expect(await DraftService.load('pengkajian', 1), isNull);
  });

  test('clear menghapus draf', () async {
    await DraftService.save('sap', 1, {'a': 1});
    await DraftService.clear('sap', 1);
    expect(await DraftService.load('sap', 1), isNull);
  });

  test('map kosong tidak disimpan', () async {
    await DraftService.save('sap', 1, {});
    expect(await DraftService.load('sap', 1), isNull);
  });
}
