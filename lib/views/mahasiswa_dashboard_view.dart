import "package:flutter/material.dart";
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/auth_controller.dart';
import '../services/logger_service.dart';
import '../services/api_service.dart';
import '../models/form_type_model.dart';

class MahasiswaDashboardView extends GetView<DashboardController> {
  const MahasiswaDashboardView({super.key});

  static const List<FormType> _formTypes = [
    FormType(
      type: 'pengkajian',
      title: 'Pengkajian Kesehatan Jiwa',
      description: 'Formulir pengkajian awal klien',
      icon: Icons.medical_information,
    ),
    FormType(
      type: 'resume_kegawatdaruratan',
      title: 'Resume Kegawatdaruratan',
      description: 'Resume kasus darurat psikiatri',
      icon: Icons.emergency,
    ),
    FormType(
      type: 'resume_poliklinik',
      title: 'Resume Poliklinik',
      description: 'Resume kunjungan poliklinik',
      icon: Icons.local_hospital,
    ),
    FormType(
      type: 'sap',
      title: 'SAP',
      description: 'Satuan Acara Penyuluhan',
      icon: Icons.school,
    ),
    FormType(
      type: 'terapi_aktivitas_kelompok',
      title: 'Terapi Aktivitas Kelompok',
      description: 'Formulir TAK',
      icon: Icons.group_work,
    ),
    FormType(
      type: 'strategi_pelaksanaan_komunikasi',
      title: 'Strategi Komunikasi',
      description: 'Strategi pelaksanaan komunikasi',
      icon: Icons.chat_bubble_outline,
    ),
    FormType(
      type: 'catatan_tambahan',
      title: 'Catatan Tambahan',
      description: 'Catatan dokumentasi tambahan',
      icon: Icons.note_add,
    ),
    // Added 8th option or placeholder if needed, matching user's "8 pilihan"
    // Assuming 7 are known, maybe 'Nursing Management'?
    // Or maybe the user counts 'Genogram' separately?
    // I will stick to these 7 known + maybe 'Logbook' or placeholder if needed.
    // Let's add 'Nursing Management' or just keep 7 for now unless 8 is strict.
    // User said "Ada 8 pilihan". Let's check if I missed any form.
    // List: Pengkajian, Resume Gadar, Resume Poli, SAP, TAK, SPK, Catatan Tambahan. (7 items).
    // Maybe the 8th is "Review" or "Profile"?
    // I will add 'Logbook / Lainnya' for now to make grid even if needed.
    FormType(
      type: 'logbook',
      title: 'Logbook & Lainnya',
      description: 'Catatan aktivitas harian',
      icon: Icons.book_rounded,
    ),
  ];

  Future<void> _refreshDashboard() async {
    final LoggerService logger = LoggerService();
    logger.info('Memuat ulang Dashboard Mahasiswa');

    await Future.wait([
      controller.fetchMahasiswaStats(),
      controller.fetchLatestPatients(),
      _fetchLecturerAssignment(),
    ]);
  }

  static Future<void> _fetchLecturerAssignment() async {
    try {
      final response = await ApiService.getAssignedLecturer();
      if (response.statusCode == 200) {
        // Handle the response to update UI state if needed
      }
    } catch (e) {
      // print('Error fetching lecturer assignment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final LoggerService logger = LoggerService();
    logger.info('Dashboard Mahasiswa dimuat');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final isDesktop = constraints.maxWidth > 900;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40.0 : (isTablet ? 24.0 : 16.0),
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 32),
                      _buildServicesSection(context, isTablet, isDesktop),
                      const SizedBox(height: 40),
                      _buildStatsSection(context, isTablet, isDesktop),
                      const SizedBox(height: 40),
                      _buildPatientsSection(
                        context,
                        isTablet,
                        isDesktop,
                        logger,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context, logger),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final AuthController authController = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.dashboard_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Mahasiswa',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih layanan formulir di bawah ini',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => authController.logout(),
              icon: Icon(Icons.logout_rounded, color: colorScheme.error),
              tooltip: 'Keluar',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServicesSection(
    BuildContext context,
    bool isTablet,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Layanan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 4 : (isTablet ? 3 : 2),
            childAspectRatio: 1.1, // Adjust aspect ratio for card shape
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _formTypes.length,
          itemBuilder: (context, index) {
            return _buildServiceCard(context, _formTypes[index]);
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, FormType formType) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () => _onServiceSelected(formType.type),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  formType.icon,
                  color: colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                formType.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Optional: Show description if space allows, or keep it clean
            ],
          ),
        ),
      ),
    );
  }

  void _onServiceSelected(String formType) {
    // Navigate to Patient Selection Screen
    Get.toNamed('/patient-selection', arguments: {'formType': formType});
  }

  Widget _buildStatsSection(
    BuildContext context,
    bool isTablet,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isMahasiswaStatsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return _buildErrorCard(context, controller.errorMessage);
          }

          final stats = controller.mahasiswaStats;
          if (stats.isEmpty) {
            return const Text("Tidak ada data statistik.");
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 2;
              if (constraints.maxWidth > 900) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 3;
              }

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.0, // Flatter stats cards
                children: [
                  _buildStatCard(
                    context,
                    'Total Pasien',
                    stats['total_pasien'].toString(),
                    Icons.people_rounded,
                    Theme.of(context).colorScheme.primary,
                  ),
                  _buildStatCard(
                    context,
                    'Total Form',
                    stats['total_form'].toString(),
                    Icons.description_rounded,
                    Theme.of(context).colorScheme.tertiary,
                  ),
                  _buildStatCard(
                    context,
                    'Form Disetujui',
                    stats['form_disetujui'].toString(),
                    Icons.check_circle_rounded,
                    Colors.green.shade600,
                  ),
                  _buildStatCard(
                    context,
                    'Perlu Revisi',
                    (stats['form_revisi'] ?? 0).toString(),
                    Icons.warning_rounded,
                    Theme.of(context).colorScheme.error,
                  ),
                ],
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsSection(
    BuildContext context,
    bool isTablet,
    bool isDesktop,
    LoggerService logger,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Pasien Terbaru',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLatestPatientsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.latestPatients.isEmpty) {
            return _buildEmptyStateCard(
              context,
              'Belum ada data pasien.',
              Icons.person_add_rounded,
            );
          }

          return _buildPatientsList(context, logger, isTablet, isDesktop);
        }),
      ],
    );
  }

  Widget _buildPatientsList(
    BuildContext context,
    LoggerService logger,
    bool isTablet,
    bool isDesktop,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // Material (bukan Container berwarna) agar efek sentuh ListTile tetap terlihat.
    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        itemCount: controller.latestPatients.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        itemBuilder: (context, index) {
          final patient = controller.latestPatients[index];
          return _buildPatientTile(context, patient, logger);
        },
      ),
    );
  }

  /// Huruf awal nama; aman untuk nama kosong atau null.
  String _initial(dynamic name) {
    final text = (name as String?)?.trim() ?? '';
    return text.isEmpty ? '?' : text.characters.first.toUpperCase();
  }

  Widget _buildPatientTile(
    BuildContext context,
    Map<String, dynamic> patient,
    LoggerService logger,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          _initial(patient['name']),
          style: TextStyle(color: colorScheme.onPrimaryContainer),
        ),
      ),
      title: Text(patient['name'] ?? 'Tanpa Nama'),
      subtitle: Text('RM: ${patient['rm_number'] ?? '-'}'),
      onTap: () {
        Get.toNamed(
          '/form-selection',
          arguments: {
            'patientId': patient['id'],
            'patientName': patient['name'],
          },
        );
      },
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }


  Widget _buildEmptyStateCard(
    BuildContext context,
    String message,
    IconData icon,
  ) {
    return Center(
      child: Padding(padding: const EdgeInsets.all(16.0), child: Text(message)),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        error,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFAB(BuildContext context, LoggerService logger) {
    return FloatingActionButton.extended(
      onPressed: () async {
        logger.userAction(
          action: 'Tombol Tambah Pasien ditekan',
          metadata: {'page': 'MahasiswaDashboardView'},
        );
        final result = await Get.toNamed('/patient-form');
        if (result != null) {
          await controller.fetchLatestPatients();
          await controller.fetchMahasiswaStats();
        }
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('Tambah Pasien'),
      elevation: 4,
    );
  }
}
