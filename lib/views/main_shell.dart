import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dosen_dashboard_view.dart';
import 'mahasiswa_dashboard_view.dart';
import 'profile_view.dart';
import 'patients_list_view.dart';
import 'forms_list_view.dart';
import 'mahasiswa_bimbingan_view.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final _patientsKey = GlobalKey<PatientsListViewState>();
  final _formsKey = GlobalKey<FormsListViewState>();
  final _profileKey = GlobalKey<ProfileViewState>();

  late final List<Widget> _tabs;
  late final List<String> _tabLabels;
  late final List<Icon> _icons;
  late final List<Icon> _selectedIcons;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _initializeTabs();
  }

  void _initializeTabs() {
    final userRole = _authController.user?.role ?? 'mahasiswa';

    if (userRole == 'dosen') {
      // For dosen: Dashboard, Mahasiswa Bimbingan, Forms, Profil
      _tabs = [
        const DosenDashboardView(),
        const MahasiswaBimbinganView(), // Mahasiswa Bimbingan
        FormsListView(key: _formsKey), // Forms (submitted forms for review)
        ProfileView(key: _profileKey), // Profile
      ];
      _tabLabels = ['Dashboard', 'Bimbingan', 'Forms', 'Profil'];
      _icons = [
        const Icon(Icons.dashboard_outlined),
        const Icon(Icons.school_outlined),
        const Icon(Icons.description_outlined),
        const Icon(Icons.person_outline_rounded),
      ];
      _selectedIcons = [
        const Icon(Icons.dashboard_rounded),
        const Icon(Icons.school_rounded),
        const Icon(Icons.description_rounded),
        const Icon(Icons.person_rounded),
      ];
    } else {
      // For mahasiswa: Dashboard, Pasien, Forms, Profil
      _tabs = [
        const MahasiswaDashboardView(),
        PatientsListView(key: _patientsKey),
        FormsListView(key: _formsKey),
        ProfileView(key: _profileKey),
      ];
      _tabLabels = ['Dashboard', 'Pasien', 'Forms', 'Profil'];
      _icons = [
        const Icon(Icons.dashboard_outlined),
        const Icon(Icons.people_alt_outlined),
        const Icon(Icons.description_outlined),
        const Icon(Icons.person_outline_rounded),
      ];
      _selectedIcons = [
        const Icon(Icons.dashboard_rounded),
        const Icon(Icons.people_alt_rounded),
        const Icon(Icons.description_rounded),
        const Icon(Icons.person_rounded),
      ];
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Always refresh data when switching tabs to ensure up-to-date information
    _refreshCurrentTab(index);
  }

  void _refreshCurrentTab(int index) {
    final userRole = _authController.user?.role ?? 'mahasiswa';

    if (userRole == 'dosen') {
      switch (index) {
        case 0:
          Get.find<DashboardController>().fetchDosenStats();
          break;
        case 1:
          // Refresh mahasiswa bimbingan view - no specific refresh currently needed
          break;
        case 2:
          _formsKey.currentState?.refresh();
          break;
        case 3:
          _profileKey.currentState?.refresh();
          break;
      }
    } else {
      switch (index) {
        case 0:
          Get.find<DashboardController>().fetchMahasiswaStats();
          Get.find<DashboardController>().fetchLatestPatients();
          break;
        case 1:
          _patientsKey.currentState?.refresh();
          break;
        case 2:
          _formsKey.currentState?.refresh();
          break;
        case 3:
          _profileKey.currentState?.refresh();
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: List.generate(_tabLabels.length, (index) {
          return NavigationDestination(
            icon: _icons[index],
            selectedIcon: _selectedIcons[index],
            label: _tabLabels[index],
          );
        }),
      ),
    );
  }
}

// Removed unused _LibraryTab and _LibraryCard after adding dedicated Forms tab.
