import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamajiwa/theme/app_theme.dart';
import 'package:tamajiwa/widgets/ds/ds.dart';

Widget _host(ThemeData theme) => MaterialApp(
      theme: theme,
      home: Scaffold(
        body: ListView(padding: const EdgeInsets.all(20), children: [
          const DsPageHeader(title: 'Formulir', subtitle: '12 formulir ditemukan'),
          const DsSearchField(hint: 'Cari'),
          const SizedBox(height: 12),
          const Wrap(spacing: 8, children: [
            DsPill(label: 'Semua', selected: true),
            DsPill(label: 'RM 0012', icon: Icons.badge_outlined),
            DsBadge('4.8'),
          ]),
          const SizedBox(height: 12),
          const Wrap(spacing: 6, runSpacing: 6, children: [
            DsStatusPill(DsStatus.draft),
            DsStatusPill(DsStatus.submitted),
            DsStatusPill(DsStatus.revision),
          ]),
          const SizedBox(height: 12),
          const SizedBox(
            height: 130,
            child: DsStat(
                value: '24',
                label: 'Total pasien',
                icon: Icons.people_alt_rounded,
                highlight: true),
          ),
          const DsCard(child: Text('Kartu')),
          const DsEmpty(icon: Icons.inbox, title: 'Kosong', message: 'Belum ada data'),
          const DsError(message: 'Gagal memuat'),
          DsCta(label: 'Ajukan', onPressed: () {}),
        ]),
      ),
    );

void main() {
  for (final entry in {
    'terang': AppTheme.lightTheme,
    'gelap': AppTheme.darkTheme,
  }.entries) {
    testWidgets('komponen design system tampil tanpa error (${entry.key}, 360px)',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(entry.value));
      expect(tester.takeException(), isNull);
      expect(find.text('Formulir'), findsOneWidget);
      expect(find.text('Perlu revisi'), findsOneWidget);
    });
  }

  test('status backend dipetakan benar', () {
    expect(dsStatusFrom('submitted'), DsStatus.submitted);
    expect(dsStatusFrom('revised'), DsStatus.revision);
    expect(dsStatusFrom('approved'), DsStatus.approved);
    expect(dsStatusFrom(null), DsStatus.draft);
    expect(dsStatusFrom('apa-saja'), DsStatus.draft);
  });

  test('inisial avatar aman untuk nama kosong dan spasi ganda', () {
    expect(DsAvatar.initials(null), '?');
    expect(DsAvatar.initials('   '), '?');
    expect(DsAvatar.initials('Budi'), 'B');
    expect(DsAvatar.initials('Siti   Aminah Putri'), 'SA');
  });

  test('kontras teks ink di atas lime memenuhi WCAG AA (>= 4.5)', () {
    double lin(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    double lum(Color c) =>
        0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);

    final a = lum(AppColors.lime), b = lum(AppColors.ink);
    final ratio = (a + 0.05) / (b + 0.05);
    expect(ratio, greaterThan(4.5), reason: 'rasio = $ratio');
  });
}
