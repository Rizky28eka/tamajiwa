import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/logger_service.dart';
import '../utils/ui_helpers.dart';
import '../widgets/ds/ds.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final AuthController authController = Get.find<AuthController>();
  final LoggerService _logger = LoggerService();
  final TextEditingController _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _send() {
    final email = _email.text.trim();

    if (email.isEmpty) {
      _logger.userInteraction('Gagal lupa sandi - email kosong',
          page: 'ForgotPasswordView', data: {'email': email});
      UIHelpers.showError(
          title: 'Gagal', message: 'Mohon masukkan alamat email Anda');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _logger.userInteraction('Upaya lupa sandi gagal - email tidak valid',
          page: 'ForgotPasswordView', data: {'email': email});
      UIHelpers.showError(
          title: 'Gagal', message: 'Mohon masukkan alamat email yang valid');
      return;
    }

    _logger.userInteraction('Tombol Lupa Sandi ditekan',
        page: 'ForgotPasswordView', data: {'email': email});
    authController.sendPasswordResetLink(email);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DsRoundIcon(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Kembali',
                        onTap: () => Get.back()),
                  ),
                  const SizedBox(height: 20),
                  Text('Lupa kata sandi?', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text(
                    'Masukkan email terdaftar. Kami akan mengirim tautan untuk mengatur ulang kata sandi Anda.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() => DsCta(
                        label: 'Kirim tautan reset',
                        loading: authController.isLoading.value,
                        onPressed: _send,
                      )),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah ingat?', style: theme.textTheme.bodyMedium),
                      TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Kembali ke masuk')),
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
