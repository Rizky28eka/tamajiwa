import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_selection_controller.dart';
import '../models/form_model.dart';
import '../services/logger_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';
import 'form_detail_view.dart';

class FormSelectionView extends GetView<FormSelectionController> {
  final LoggerService _logger = LoggerService();

  FormSelectionView({super.key});

  final List<FormType> _formTypes = [
    FormType(
      type: 'pengkajian',
      title: 'Pengkajian Kesehatan Jiwa',
      description: 'Formulir pengkajian awal klien',
      icon: Icons.medical_information_rounded,
    ),
    FormType(
      type: 'resume_kegawatdaruratan',
      title: 'Resume Kegawatdaruratan Psikiatri',
      description: 'Resume untuk kasus kegawatdaruratan psikiatri',
      icon: Icons.emergency_rounded,
    ),
    FormType(
      type: 'resume_poliklinik',
      title: 'Resume Poliklinik',
      description: 'Resume untuk kunjungan poliklinik',
      icon: Icons.local_hospital_rounded,
    ),
    FormType(
      type: 'sap',
      title: 'SAP (Satuan Acara Penyuluhan)',
      description: 'Satuan acara penyuluhan kesehatan',
      icon: Icons.school_rounded,
    ),
    FormType(
      type: 'terapi_aktivitas_kelompok',
      title: 'Terapi Aktivitas Kelompok',
      description: 'Formulir terapi aktivitas kelompok',
      icon: Icons.group_work_rounded,
    ),
    FormType(
      type: 'strategi_pelaksanaan_komunikasi',
      title: 'Strategi Pelaksanaan Komunikasi',
      description: 'Strategi pelaksanaan komunikasi terapeutik',
      icon: Icons.chat_bubble_outline_rounded,
    ),
    FormType(
      type: 'catatan_tambahan',
      title: 'Catatan Tambahan',
      description: 'Catatan tambahan untuk dokumentasi',
      icon: Icons.note_add_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(FormSelectionController());

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.ink,
          backgroundColor: AppColors.lime,
          onRefresh: controller.fetchForms,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Row(children: [
                    DsRoundIcon(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Kembali',
                        onTap: () => Get.back()),
                  ]),
                  const SizedBox(height: 16),
                  _hero(context),
                  const SizedBox(height: 24),
                  Obx(() => _content(context)),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: DsStickyCta(
        child: DsCta(
          label: 'Buat formulir baru',
          icon: Icons.add_rounded,
          onPressed: () => _showNewFormSheet(context),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg + 6),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          DsAvatar(name: controller.patientName, size: 68),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PASIEN', style: theme.textTheme.labelSmall),
                  const SizedBox(height: 4),
                  Text(controller.patientName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall),
                ]),
          ),
        ]),
        const SizedBox(height: 18),
        Obx(() {
          final forms = controller.forms;
          int count(String s) => forms.where((f) => f.status == s).length;
          return Wrap(spacing: 8, runSpacing: 8, children: [
            DsPill(
                icon: Icons.description_outlined,
                label: '${forms.length} formulir'),
            DsPill(
                icon: Icons.check_circle_outline_rounded,
                label: '${count('approved')} disetujui'),
            if (count('revised') > 0)
              DsPill(
                  icon: Icons.replay_rounded,
                  label: '${count('revised')} revisi',
                  selected: true),
          ]);
        }),
      ]),
    );
  }

  Widget _content(BuildContext context) {
    if (controller.isLoading) {
      return const Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()));
    }
    if (controller.errorMessage.isNotEmpty) {
      return DsError(
          message: controller.errorMessage, onRetry: controller.fetchForms);
    }
    if (controller.forms.isEmpty) {
      return DsEmpty(
        icon: Icons.note_add_outlined,
        title: 'Belum ada formulir',
        message: 'Mulai dengan Pengkajian Kesehatan Jiwa untuk pasien ini.',
        actionLabel: 'Buat formulir baru',
        onAction: () => _showNewFormSheet(context),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const DsSectionTitle('Formulir pasien'),
      for (final f in controller.forms) ...[
        _formCard(context, f),
        const SizedBox(height: 10),
      ],
    ]);
  }

  Widget _formCard(BuildContext context, FormModel form) {
    final theme = Theme.of(context);
    return DsCard(
      radius: AppRadius.md,
      onTap: () => _showFormOptions(form),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: AppColors.limeSoft,
              borderRadius: BorderRadius.circular(16)),
          child: Icon(_getFormIcon(form.type), color: AppColors.ink),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(controller.getFormTitle(form.type),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(form.createdAt.toString().substring(0, 10),
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            DsStatusPill.raw(form.status),
          ]),
        ),
        const Icon(Icons.more_vert_rounded),
      ]),
    );
  }

  void _showNewFormSheet(BuildContext context) {
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Get.theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Pilih jenis formulir',
                  style: Get.theme.textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(shrinkWrap: true, children: [
                for (final t in _formTypes)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                          color: AppColors.lime, shape: BoxShape.circle),
                      child: Icon(t.icon, color: AppColors.ink, size: 22),
                    ),
                    title: Text(t.title,
                        style: Get.theme.textTheme.titleSmall),
                    subtitle: Text(t.description),
                    trailing: const Icon(Icons.add_rounded),
                    onTap: () {
                      Get.back();
                      controller.createForm(t.type);
                    },
                  ),
              ]),
            ),
          ]),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showFormOptions(FormModel form) {
    final colorScheme = Get.theme.colorScheme;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Opsi Formulir',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              icon: Icons.edit_rounded,
              title: 'Edit Formulir',
              iconColor: colorScheme.primary,
              onTap: () {
                Get.back();
                controller.openExistingForm(form);
              },
            ),
            if (form.status != 'approved')
              _buildOptionTile(
                icon: Icons.delete_rounded,
                title: 'Hapus Formulir',
                iconColor: colorScheme.error,
                onTap: () {
                  Get.back();
                  _confirmDeleteForm(form);
                },
              ),
            _buildOptionTile(
              icon: Icons.info_rounded,
              title: 'Detail Formulir',
              subtitle:
                  'Status: ${_getStatusText(form.status)} • ${form.createdAt.toString().substring(0, 16)}',
              iconColor: colorScheme.tertiary,
              onTap: () {
                Get.back();
                _showFormDetails(form);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => Get.back(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Get.theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Get.theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  void _confirmDeleteForm(FormModel form) {
    final colorScheme = Get.theme.colorScheme;

    Get.dialog(
      AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text(
          "Apakah Anda yakin ingin menghapus formulir ${controller.getFormTitle(form.type)}?\n\nTindakan ini tidak dapat dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _logger.userAction(
                action: 'Penghapusan form dibatalkan',
                metadata: {'formId': form.id.toString(), 'formType': form.type},
              );
            },
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.deleteForm(form);
            },
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showFormDetails(FormModel form) {
    Get.to(() => const FormDetailView(), arguments: form);
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'submitted':
        return 'Menunggu Review';
      case 'approved':
        return 'Disetujui';
      case 'revised':
        return 'Perlu Revisi';
      default:
        return status;
    }
  }

  IconData _getFormIcon(String type) {
    switch (type) {
      case 'pengkajian':
        return Icons.medical_information_rounded;
      case 'resume_kegawatdaruratan':
        return Icons.emergency_rounded;
      case 'resume_poliklinik':
        return Icons.local_hospital_rounded;
      case 'sap':
        return Icons.school_rounded;
      case 'terapi_aktivitas_kelompok':
        return Icons.group_work_rounded;
      case 'strategi_pelaksanaan_komunikasi':
        return Icons.chat_bubble_outline_rounded;
      case 'catatan_tambahan':
        return Icons.note_add_rounded;
      default:
        return Icons.description_rounded;
    }
  }
}

class FormType {
  final String type;
  final String title;
  final String description;
  final IconData icon;

  FormType({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
  });
}
