import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../services/logger_service.dart';
import '../theme/app_theme.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  final SplashController controller = Get.find<SplashController>();

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
    LoggerService().info('SplashView initialized');
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.lime,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                      color: AppColors.ink, shape: BoxShape.circle),
                  child: const Icon(Icons.spa_rounded,
                      color: AppColors.lime, size: 36),
                ),
                const SizedBox(height: 28),
                const Text('Tamajiwa',
                    style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        height: 1)),
                const SizedBox(height: 10),
                Text('Aplikasi asuhan keperawatan jiwa',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: AppColors.ink)),
                const Spacer(),
                Row(children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: AppColors.ink),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => Text(
                          controller.statusMessage.value,
                          style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w600),
                        )),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
