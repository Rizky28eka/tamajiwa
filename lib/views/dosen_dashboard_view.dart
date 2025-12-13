import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../services/logger_service.dart';

class DosenDashboardView extends StatelessWidget {
  const DosenDashboardView({super.key});

  Future<void> _refreshDashboard() async {
    final LoggerService logger = LoggerService();
    logger.info('Memuat ulang Dashboard Dosen');
    final AuthController authController = Get.find();
    final DashboardController dashboardController = Get.find();

    await authController.getUserProfile();
    await dashboardController.fetchDosenStats();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final LoggerService logger = LoggerService();
    logger.info('DosenDashboardView dimuat');
    final AuthController authController = Get.find();
    final DashboardController dashboardController = Get.put(
      DashboardController(),
    );

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;
    final contentPadding = isLargeScreen ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(contentPadding),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLargeScreen ? 1200 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Custom Header
                    _buildHeader(
                      context,
                      authController,
                      colorScheme,
                      textTheme,
                      isLargeScreen,
                    ),
                    SizedBox(height: isLargeScreen ? 40 : 32),

                    // Statistics Section
                    _buildStatisticsSection(
                      context,
                      dashboardController,
                      colorScheme,
                      textTheme,
                      isLargeScreen,
                    ),
                    SizedBox(height: isLargeScreen ? 40 : 32),

                    // Quick Actions Section
                    _buildQuickActionsSection(
                      context,
                      colorScheme,
                      textTheme,
                      isLargeScreen,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AuthController authController,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isLargeScreen,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isLargeScreen ? 28 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.dashboard_rounded,
              color: colorScheme.onPrimary,
              size: isLargeScreen ? 36 : 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  if (authController.user != null) {
                    return Text(
                      'Selamat Datang,',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                        fontSize: isLargeScreen ? 15 : 14,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 4),
                Obx(() {
                  if (authController.user != null) {
                    return Text(
                      authController.user!.name,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                        fontSize: isLargeScreen ? 26 : 22,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                  return Text(
                    'Memuat...',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                      fontSize: isLargeScreen ? 26 : 22,
                    ),
                  );
                }),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Dosen',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/profile'),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    DashboardController dashboardController,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isLargeScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 20),
          child: Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: colorScheme.primary,
                size: isLargeScreen ? 28 : 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Statistik Form',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isLargeScreen ? 24 : 20,
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          if (dashboardController.isDosenStatsLoading) {
            return _buildLoadingState(colorScheme);
          }
          if (dashboardController.errorMessage.isNotEmpty) {
            return _buildErrorState(
              colorScheme,
              dashboardController.errorMessage,
            );
          }
          final stats = dashboardController.dosenStats;
          if (stats.isEmpty) {
            return _buildEmptyState(colorScheme);
          }
          return _buildStatsGrid(
            context,
            stats,
            colorScheme,
            textTheme,
            isLargeScreen,
          );
        }),
      ],
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(48),
      alignment: Alignment.center,
      child: CircularProgressIndicator(color: colorScheme.primary),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.error.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Error: $message',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 56,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Statistik belum tersedia saat ini',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    Map<String, dynamic> stats,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isLargeScreen,
  ) {
    final List<Map<String, dynamic>> statCards = [
      {
        'title': 'Total Mahasiswa',
        'value': stats['total_mahasiswa'].toString(),
        'icon': Icons.people_rounded,
        'color': Colors.blue,
      },
      {
        'title': 'Total Form',
        'value': stats['total_form'].toString(),
        'icon': Icons.description_rounded,
        'color': Colors.green,
      },
      {
        'title': 'Menunggu Review',
        'value': stats['form_menunggu_review'].toString(),
        'icon': Icons.pending_actions_rounded,
        'color': Colors.orange,
      },
      {
        'title': 'Form Disetujui',
        'value': stats['form_disetujui'].toString(),
        'icon': Icons.check_circle_rounded,
        'color': Colors.teal,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : (constraints.maxWidth > 600 ? 2 : 2);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isLargeScreen ? 20 : 12,
            mainAxisSpacing: isLargeScreen ? 20 : 12,
            childAspectRatio: isLargeScreen ? 1.3 : 1.1,
          ),
          itemCount: statCards.length,
          itemBuilder: (context, index) => _buildStatCard(
            statCards[index]['title'],
            statCards[index]['value'],
            statCards[index]['color'],
            statCards[index]['icon'],
            colorScheme,
            textTheme,
            isLargeScreen,
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isLargeScreen,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: isLargeScreen ? 32 : 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontSize: isLargeScreen ? 32 : 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                fontSize: isLargeScreen ? 14 : 12,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isLargeScreen,
  ) {
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.medical_information_rounded,
        'title': 'Manajemen Diagnosis',
        'subtitle': 'Kelola daftar diagnosis keperawatan',
        'color': Colors.red,
        'route': '/diagnoses',
      },
      {
        'icon': Icons.volunteer_activism_rounded,
        'title': 'Manajemen Intervensi',
        'subtitle': 'Kelola daftar intervensi keperawatan',
        'color': Colors.purple,
        'route': '/interventions',
      },
      {
        'icon': Icons.rate_review_rounded,
        'title': 'Review & Revisi Form',
        'subtitle': 'Review form yang dikumpulkan mahasiswa',
        'color': Colors.indigo,
        'route': '/dosen-review-dashboard',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 20),
          child: Row(
            children: [
              Icon(
                Icons.dashboard_customize_rounded,
                color: colorScheme.primary,
                size: isLargeScreen ? 28 : 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Aksi Cepat',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isLargeScreen ? 24 : 20,
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return Row(
                children: actions
                    .map(
                      (action) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _buildActionCard(
                            action,
                            colorScheme,
                            textTheme,
                            isLargeScreen,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            }
            return Column(
              children: actions
                  .map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildActionCard(
                        action,
                        colorScheme,
                        textTheme,
                        isLargeScreen,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    Map<String, dynamic> action,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isLargeScreen,
  ) {
    final Color actionColor = action['color'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(action['route']),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        actionColor.withOpacity(0.2),
                        actionColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    action['icon'],
                    color: actionColor,
                    size: isLargeScreen ? 32 : 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action['title'],
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isLargeScreen ? 17 : 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action['subtitle'],
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: isLargeScreen ? 14 : 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
