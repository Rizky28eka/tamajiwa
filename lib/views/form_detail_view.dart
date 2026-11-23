import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/form_model.dart';
import '../models/review_comment_model.dart';
import '../services/review_service.dart';
import '../theme/app_theme.dart';
import '../utils/form_types.dart';
import '../widgets/ds/ds.dart';
import 'dart:convert';
import '../services/logger_service.dart';
import '../services/role_guard.dart';
import '../utils/ui_helpers.dart';
import 'genogram_builder_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FormDetailView extends StatefulWidget {
  const FormDetailView({super.key});

  @override
  State<FormDetailView> createState() => _FormDetailViewState();
}

class _FormDetailViewState extends State<FormDetailView> {
  final FormController formController = Get.put(FormController());
  final AuthController authController = Get.find<AuthController>();
  final LoggerService _logger = LoggerService();
  final TextEditingController _commentController = TextEditingController();

  late FormModel form;
  bool isLecturer = false; // legacy flag retained for minimal change
  bool _genogramAvailable = false;

  @override
  void initState() {
    super.initState();
    // Retrieve form from arguments or fetch if only ID is passed
    final args = Get.arguments;
    if (args is FormModel) {
      form = args;
    } else if (args is Map<String, dynamic> && args['form'] is FormModel) {
      form = args['form'];
    } else {
      // Fallback or error handling
      Get.back();
      return;
    }

    _commentController.text = form.comments ?? '';
    isLecturer = RoleGuard.isDosen();
    _genogramAvailable =
        form.genogram != null ||
        (form.data != null &&
            (form.data!['section_9']?['structure'] != null ||
                form.data!['genogram']?['structure'] != null));
  }

  // Prevent unexpected setState during hot reload by pausing auto-refresh logic
  @override
  void reassemble() {
    // Avoid triggering async refreshes automatically during hot reload.
    // Keeps the widget stable when Flutter rebuilds the tree.
    super.reassemble();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  int _genogramMemberCount() {
    try {
      if (form.genogram?.structure != null) {
        final members = form.genogram!.structure!['members'];
        if (members is List) return members.length;
      }
      if (form.data?['section_9']?['structure'] != null) {
        final members = form.data!['section_9']['structure']['members'];
        if (members is List) return members.length;
      }
      if (form.data?['genogram']?['structure'] != null) {
        final members = form.data!['genogram']['structure']['members'];
        if (members is List) return members.length;
      }
    } catch (e) {
      // ignore error
    }
    return 0;
  }

  int _genogramConnectionCount() {
    try {
      if (form.genogram?.structure != null) {
        final connections = form.genogram!.structure!['connections'];
        if (connections is List) return connections.length;
      }
      if (form.data?['section_9']?['structure'] != null) {
        final connections = form.data!['section_9']['structure']['connections'];
        if (connections is List) return connections.length;
      }
      if (form.data?['genogram']?['structure'] != null) {
        final connections = form.data!['genogram']['structure']['connections'];
        if (connections is List) return connections.length;
      }
    } catch (e) {
      // ignore error
    }
    return 0;
  }

  Future<void> _refreshFormData() async {
    _logger.info('Memuat ulang detail data form');
    // Fetch the specific form by id to ensure we get the full payload (data included)
    final fetchedForm = await formController.getFormById(form.id);
    if (!mounted) return;
    if (fetchedForm != null) {
      setState(() {
        form = fetchedForm;
        _commentController.text = form.comments ?? '';
      });
    }
  }

  String _humanize(String key) {
    final t = key.replaceAll('_', ' ').trim();
    return t.isEmpty ? key : t[0].toUpperCase() + t.substring(1);
  }

  Future<void> _toggleResolved(ReviewComment c) async {
    try {
      final res = await ReviewService.toggleResolved(c.id);
      if (res.statusCode != 200) {
        UIHelpers.showError(
            title: 'Gagal', message: 'Tidak dapat memperbarui komentar');
        return;
      }
      final updated =
          ReviewComment.fromJson(json.decode(res.body) as Map<String, dynamic>);
      if (!mounted) return;
      setState(() {
        form = form.copyWith(reviewComments: [
          for (final x in form.reviewComments) x.id == c.id ? updated : x,
        ]);
      });
    } catch (e) {
      _logger.error('Gagal mengubah status komentar', error: e);
      UIHelpers.showError(title: 'Gagal', message: 'Periksa koneksi Anda');
    }
  }

  Widget _commentTile(ReviewComment c) {
    final theme = Theme.of(context);
    final canResolve = !isLecturer;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: c.isResolved
            ? theme.colorScheme.surfaceContainerHighest
            : AppColors.limeSoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              ((c.reviewerName ?? 'Dosen') +
                      (c.isResolved ? ' · selesai' : ''))
                  .toUpperCase(),
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: c.isResolved ? null : AppColors.ink),
            ),
            const SizedBox(height: 3),
            Text(c.comment,
                style: TextStyle(
                    color: c.isResolved
                        ? theme.colorScheme.onSurfaceVariant
                        : AppColors.ink,
                    decoration:
                        c.isResolved ? TextDecoration.lineThrough : null)),
          ]),
        ),
        if (canResolve)
          IconButton(
            tooltip: c.isResolved ? 'Buka kembali' : 'Tandai sudah diperbaiki',
            icon: Icon(c.isResolved
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded),
            color: c.isResolved ? AppColors.success : AppColors.ink,
            onPressed: () => _toggleResolved(c),
          ),
      ]),
    );
  }

  List<Widget> _buildFormDataCards() {
    final theme = Theme.of(context);
    final cards = <Widget>[];
    form.data!.forEach((key, value) {
      if (value == null) return;
      final comments = form.reviewComments.where((c) => c.section == key);

      Widget content;
      if (value is Map) {
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final e in value.entries)
              if (e.value != null && e.value.toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_humanize(e.key.toString()).toUpperCase(),
                          style: theme.textTheme.labelSmall),
                      const SizedBox(height: 3),
                      Text(e.value.toString()),
                    ],
                  ),
                ),
          ],
        );
      } else {
        content = Text(value.toString());
      }

      cards.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DsCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_humanize(key), style: theme.textTheme.titleMedium),
            const SizedBox(height: 14),
            content,
            for (final c in comments) _commentTile(c),
          ]),
        ),
      ));
    });
    return cards;
  }

  Future<void> _updateStatus(String status) async {
    _logger.userAction(
      action: 'Memperbarui status form',
      metadata: {'formId': form.id.toString(), 'status': status},
    );

    await formController.updateForm(
      id: form.id,
      status: status,
      comments: _commentController.text,
    );

    if (!mounted) return;
    setState(() {
      form = form.copyWith(status: status, comments: _commentController.text);
    });

    UIHelpers.showSuccess(
      title: 'Sukses',
      message: 'Status form berhasil diperbarui',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final general = form.reviewComments.where((c) => c.section == null).toList();
    final open = form.reviewComments.where((c) => !c.isResolved).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail formulir')),
      body: RefreshIndicator(
        color: AppColors.ink,
        backgroundColor: AppColors.lime,
        onRefresh: _refreshFormData,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                DsCard(
                  child: Row(children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                          color: AppColors.lime,
                          borderRadius: BorderRadius.circular(16)),
                      child: Icon(FormTypes.icon(form.type),
                          color: AppColors.ink),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(FormTypes.title(form.type),
                                style: theme.textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                                'Diperbarui ${form.updatedAt.toString().substring(0, 16)}',
                                style: theme.textTheme.bodySmall),
                            const SizedBox(height: 8),
                            Row(children: [
                              DsStatusPill.raw(form.status),
                              if (form.score != null) ...[
                                const SizedBox(width: 8),
                                DsBadge('Nilai ${form.score}'),
                              ],
                            ]),
                          ]),
                    ),
                  ]),
                ),
                if (!isLecturer && form.status == 'revised' && open > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(children: [
                      const Icon(Icons.replay_rounded, color: AppColors.ink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '$open komentar dosen perlu Anda perbaiki. Tandai yang sudah selesai.',
                          style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),
                const DsSectionTitle('Isi formulir'),
                if (form.data != null && form.data!.isNotEmpty)
                  ..._buildFormDataCards()
                else
                  const DsEmpty(
                      icon: Icons.description_outlined,
                      title: 'Tidak ada data formulir'),
                if (_genogramAvailable) ...[
                  const SizedBox(height: 8),
                  const DsSectionTitle('Genogram'),
                  DsCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(spacing: 8, runSpacing: 8, children: [
                            DsPill(
                                icon: Icons.people_outline_rounded,
                                label: '${_genogramMemberCount()} anggota'),
                            DsPill(
                                icon: Icons.share_outlined,
                                label: '${_genogramConnectionCount()} hubungan'),
                          ]),
                          const SizedBox(height: 14),
                          Row(children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _openGenogram,
                                child: const Text('Lihat'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _previewSvg,
                                child: const Text('Pratinjau SVG'),
                              ),
                            ),
                          ]),
                        ]),
                  ),
                ],
                const SizedBox(height: 20),
                const DsSectionTitle('Komentar & persetujuan'),
                if (isLecturer) ...[
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Komentar dosen',
                      hintText: 'Tambahkan catatan atau revisi di sini…',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus('revised'),
                        child: const Text('Minta revisi'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _updateStatus('approved'),
                        child: const Text('Setujui'),
                      ),
                    ),
                  ]),
                ] else ...[
                  if (general.isEmpty &&
                      (form.comments == null || form.comments!.isEmpty))
                    Text('Belum ada komentar.', style: theme.textTheme.bodySmall),
                  for (final c in general) _commentTile(c),
                  if (general.isEmpty &&
                      form.comments != null &&
                      form.comments!.isNotEmpty)
                    DsCard(child: Text(form.comments!)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openGenogram() {
    final struct = form.genogram?.structure ??
        (form.data?['genogram']?['structure'] ??
            form.data?['section_9']?['structure']);
    final notes = form.genogram?.notes ??
        (form.data?['genogram']?['notes'] ??
            form.data?['section_9']?['notes']) ??
        '';
    Get.to(
      () => GenogramBuilderView(
        initialData: {'structure': struct, 'notes': notes},
      ),
      arguments: {'readOnly': true},
    );
  }

  Future<void> _previewSvg() async {
    final svg = await formController.fetchGenogramSvg(form.id);
    if (svg == null) {
      UIHelpers.showError(
        title: 'Tidak tersedia',
        message: 'Pratinjau genogram tidak tersedia',
      );
      return;
    }
    Get.dialog(
      AlertDialog(
        title: const Text('Pratinjau genogram'),
        content: SizedBox(
          width: 400,
          height: 240,
          child: SvgPicture.string(svg, fit: BoxFit.contain),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Tutup')),
        ],
      ),
    );
  }
}
