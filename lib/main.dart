import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages.dart';
import 'constants/app_routes.dart';
import 'theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'services/logger_service.dart';
import 'constants/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Logger
  LoggerService().init();
  LoggerService().appStartup(environment: 'development');
 
  // Muat alamat API yang disimpan pengguna sebelum ada panggilan jaringan.
  await ApiConfig.load();

  // Initialize AuthController permanently
  final authController = AuthController();
  await authController.initAuth();
  Get.put(authController, permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tamajiwa',
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
