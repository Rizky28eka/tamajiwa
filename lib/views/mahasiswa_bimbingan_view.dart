import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

import '../services/logger_service.dart';
import '../utils/ui_helpers.dart';

class MahasiswaBimbinganView extends StatefulWidget {
  const MahasiswaBimbinganView({super.key});

  @override
  State<MahasiswaBimbinganView> createState() => _MahasiswaBimbinganViewState();
}

class _MahasiswaBimbinganViewState extends State<MahasiswaBimbinganView> {
  final LoggerService _logger = LoggerService();

  @override
  void initState() {
    super.initState();
    _logger.info('MahasiswaBimbinganView diinisialisasi');
  }

  void _showApproveDialog(Map<String, dynamic> student) {
    Get.defaultDialog(
      title: "Konfirmasi Mahasiswa",
      middleText: "Apakah Anda yakin ingin menyetujui ${student['name']}?",
      textConfirm: "Setujui",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      cancelTextColor: Theme.of(context).colorScheme.onSurface,
      buttonColor: Theme.of(context).colorScheme.primary,
      onConfirm: () {
        _logger.userAction(
          action: 'Menyetujui Mahasiswa',
          metadata: {
            'studentId': student['id'],
            'studentName': student['name'],
          },
        );
        UIHelpers.showSuccess(
          title: "Persetujuan",
          message: "Mahasiswa ${student['name']} berhasil disetujui",
        );
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;
    final contentPadding = isLargeScreen ? 32.0 : 16.0;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          _logger.info('Me-refresh daftar mahasiswa bimbingan');
        },
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
                  // Header Section
                  _buildHeader(context, colorScheme, textTheme, isLargeScreen),
                  SizedBox(height: isLargeScreen ? 32 : 24),

                  // Content Section
                  _buildStudentsList(
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
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isLargeScreen,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: colorScheme.primary,
                  size: isLargeScreen ? 32 : 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daftar Mahasiswa Bimbingan',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                        fontSize: isLargeScreen ? 24 : 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola dan pantau mahasiswa bimbingan Anda',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.75),
                        fontSize: isLargeScreen ? 15 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isLargeScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Mahasiswa',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isLargeScreen ? 20 : 18,
            ),
          ),
        ),
        FutureBuilder(
          future: ApiService.getAssignedStudents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState(colorScheme);
            }

            if (snapshot.hasError) {
              return _buildErrorState(colorScheme, snapshot.error.toString());
            }

            if (snapshot.hasData) {
              final response = snapshot.data!;
              if (response.statusCode == 200) {
                final data = response.body;
                final parsedData = json.decode(data);
                final students = parsedData['students'] as List<dynamic>;

                if (students.isEmpty) {
                  return _buildEmptyState(colorScheme);
                }

                return _buildStudentsGrid(
                  context,
                  students,
                  colorScheme,
                  textTheme,
                  isLargeScreen,
                );
              } else {
                return _buildErrorState(
                  colorScheme,
                  'Tidak dapat memuat daftar mahasiswa',
                );
              }
            }

            return _buildEmptyState(colorScheme);
          },
        ),
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
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(message, style: TextStyle(color: colorScheme.error)),
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
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 56,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada mahasiswa',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mahasiswa bimbingan akan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsGrid(
    BuildContext context,
    List<dynamic> students,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isLargeScreen,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : (constraints.maxWidth > 600 ? 2 : 1);

        if (crossAxisCount == 1) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildStudentCard(
              context,
              students[index],
              colorScheme,
              textTheme,
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isLargeScreen ? 3.5 : 3,
          ),
          itemCount: students.length,
          itemBuilder: (context, index) => _buildStudentCard(
            context,
            students[index],
            colorScheme,
            textTheme,
          ),
        );
      },
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    Map<String, dynamic> student,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            Get.toNamed('/patients-for-student', arguments: student['id']);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.primaryContainer.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        student['name'] ?? 'Mahasiswa Tidak Diketahui',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student['email'] ?? 'Email Tidak Diketahui',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (String value) {
                    if (value == 'approve') {
                      _showApproveDialog(student);
                    } else if (value == 'review-forms') {
                      Get.toNamed('/dosen-review-dashboard');
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'review-forms',
                      child: Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          const Text('Tinjau Form'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'approve',
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          const Text('Setujui Mahasiswa'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
