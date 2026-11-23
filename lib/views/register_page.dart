import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamajiwa/controllers/auth_controller.dart';
import '../services/logger_service.dart';
import '../widgets/ds/ds.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthController controller = Get.find<AuthController>();
  final LoggerService _logger = LoggerService();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  String _role = 'mahasiswa';
  bool _hidePassword = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _logger.userInteraction(
      'Register button pressed',
      page: 'RegisterPage',
      data: {
        'name': _name.text,
        'email': _email.text,
        'hasPassword': _password.text.isNotEmpty,
        'role': _role,
      },
    );
    controller.register(_name.text, _email.text, _password.text, _role);
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
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
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
                    Text('Buat akun', style: theme.textTheme.displaySmall),
                    const SizedBox(height: 6),
                    Text('Mulai dokumentasikan asuhan keperawatan Anda.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 24),
                    Text('SAYA ADALAH', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 8),
                    Row(children: [
                      for (final r in const ['mahasiswa', 'dosen']) ...[
                        DsPill(
                          label: r == 'mahasiswa' ? 'Mahasiswa' : 'Dosen',
                          icon: r == 'mahasiswa'
                              ? Icons.school_outlined
                              : Icons.badge_outlined,
                          selected: _role == r,
                          onTap: () => setState(() => _role = r),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ]),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nama lengkap',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email wajib diisi';
                        if (!GetUtils.isEmail(v)) return 'Format email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Kata sandi',
                        helperText: 'Minimal 8 karakter',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
                        if (v.length < 8) return 'Kata sandi minimal 8 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirm,
                      obscureText: _hideConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi kata sandi',
                        prefixIcon: const Icon(Icons.lock_reset_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_hideConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () =>
                              setState(() => _hideConfirm = !_hideConfirm),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Konfirmasi kata sandi wajib diisi';
                        }
                        if (v != _password.text) return 'Kata sandi tidak cocok';
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    Obx(() => DsCta(
                          label: 'Daftar sekarang',
                          loading: controller.isLoading.value,
                          onPressed: _submit,
                        )),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sudah punya akun?',
                            style: theme.textTheme.bodyMedium),
                        TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Masuk')),
                      ],
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
}
