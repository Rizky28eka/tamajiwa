import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../constants/api_config.dart';
import '../constants/app_routes.dart';
import '../services/logger_service.dart';
import '../theme/app_theme.dart';
import '../utils/ui_helpers.dart';
import '../widgets/ds/ds.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController authController = Get.find<AuthController>();
  final LoggerService _logger = LoggerService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    _logger.userInteraction(
      'Tombol Masuk ditekan',
      page: 'LoginView',
      data: {
        'email': _email.text.trim(),
        'hasPassword': _password.text.isNotEmpty,
      },
    );
    if (_email.text.isEmpty || _password.text.isEmpty) {
      UIHelpers.showWarning(
        title: 'Perhatian',
        message: 'Email dan Kata Sandi wajib diisi',
      );
      return;
    }
    authController.login(_email.text.trim(), _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero: kartu lime dengan merek
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                              color: AppColors.ink, shape: BoxShape.circle),
                          child: const Icon(Icons.spa_rounded,
                              color: AppColors.lime, size: 28),
                        ),
                        const SizedBox(height: 28),
                        const Text('Tamajiwa',
                            style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5,
                                height: 1)),
                        const SizedBox(height: 8),
                        const Text(
                          'Dokumentasi asuhan keperawatan, lebih tertata dan mudah direview.',
                          style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Masuk', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _password,
                    obscureText: _hidePassword,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Kata sandi',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        tooltip: _hidePassword ? 'Tampilkan' : 'Sembunyikan',
                        icon: Icon(_hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                      child: const Text('Lupa kata sandi?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => DsCta(
                        label: 'Masuk',
                        loading: authController.isLoading.value,
                        onPressed: _submit,
                      )),
                  const SizedBox(height: 20),
                  Center(
                    child: DsPill(
                      icon: Icons.dns_outlined,
                      label: Uri.tryParse(ApiConfig.currentBaseUrl)?.host ??
                          'Atur server',
                      onTap: () async {
                        await Get.toNamed(AppRoutes.serverSetup);
                        if (mounted) setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Belum punya akun?', style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.register),
                        child: const Text('Daftar sekarang'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
