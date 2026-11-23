import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/api_config.dart';
import '../constants/app_routes.dart';
import '../services/server_check_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';

/// Layar tempat pengguna memasukkan alamat API server Tamajiwa.
/// Dibuka otomatis saat pertama kali dan dari layar masuk.
class ServerSetupView extends StatefulWidget {
  const ServerSetupView({super.key});

  @override
  State<ServerSetupView> createState() => _ServerSetupViewState();
}

class _ServerSetupViewState extends State<ServerSetupView> {
  final _controller = TextEditingController();
  late final bool _firstRun;

  bool _testing = false;
  ServerCheckResult? _result;

  /// Alamat (sudah dinormalisasi) yang terakhir lolos tes.
  String? _verified;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _firstRun = args is Map && args['firstRun'] == true;
    if (ApiConfig.isConfigured) _controller.text = ApiConfig.currentBaseUrl;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? get _normalized => ApiConfig.normalize(_controller.text);

  bool get _insecure => (_normalized ?? '').startsWith('http://');

  Future<void> _test() async {
    final url = _normalized;
    if (url == null) {
      setState(() => _result = null);
      return;
    }
    setState(() {
      _testing = true;
      _result = null;
    });
    final r = await ServerCheckService.check(url);
    if (!mounted) return;
    setState(() {
      _testing = false;
      _result = r;
      _verified = r.ok ? url : null;
    });
  }

  Future<void> _save({bool skipTest = false}) async {
    final url = _normalized;
    if (url == null) return;
    if (!skipTest && _verified != url) return;
    await ApiConfig.save(url);
    if (!mounted) return;
    if (_firstRun) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.back(result: true);
    }
  }

  Future<void> _reset() async {
    await ApiConfig.reset();
    if (!mounted) return;
    setState(() {
      _controller.text = ApiConfig.isConfigured ? ApiConfig.currentBaseUrl : '';
      _result = null;
      _verified = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = _normalized;
    final typed = _controller.text.trim().isNotEmpty;
    final invalid = typed && normalized == null;
    final canSave = normalized != null && _verified == normalized;

    return Scaffold(
      appBar: _firstRun ? null : AppBar(title: const Text('Server')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_firstRun)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.lime,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Icon(Icons.dns_rounded,
                                color: AppColors.ink, size: 36),
                            SizedBox(height: 20),
                            Text('Hubungkan ke server',
                                style: TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                    height: 1.05)),
                            SizedBox(height: 8),
                            Text(
                              'Masukkan alamat API Tamajiwa dari pengelola sistem Anda. Cukup sekali; bisa diubah nanti dari layar masuk.',
                              style: TextStyle(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w500,
                                  height: 1.35),
                            ),
                          ]),
                    )
                  else
                    Text('Alamat API', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _test(),
                    onChanged: (_) => setState(() {
                      _result = null;
                      _verified = null;
                    }),
                    decoration: InputDecoration(
                      labelText: 'Alamat API',
                      hintText: 'https://api.contoh.id/api',
                      prefixIcon: const Icon(Icons.link_rounded),
                      errorText: invalid ? 'Alamat tidak valid' : null,
                      helperText: normalized != null && normalized != _controller.text.trim()
                          ? 'Akan dipakai: $normalized'
                          : null,
                    ),
                  ),
                  if (_insecure) ...[
                    const SizedBox(height: 12),
                    _notice(
                      Icons.warning_amber_rounded,
                      'Alamat http:// tidak terenkripsi dan diblokir pada aplikasi rilis di Android. Gunakan https:// untuk pemakaian sungguhan.',
                      AppColors.warning,
                    ),
                  ],
                  if (_result != null) ...[
                    const SizedBox(height: 12),
                    _notice(
                      _result!.ok
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      _result!.message,
                      _result!.ok ? AppColors.success : AppColors.danger,
                    ),
                  ],
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: (normalized == null || _testing) ? null : _test,
                    child: _testing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2))
                        : const Text('Tes koneksi'),
                  ),
                  const SizedBox(height: 12),
                  DsCta(
                    label: _firstRun ? 'Simpan & lanjut' : 'Simpan',
                    onPressed: canSave ? _save : null,
                  ),
                  const SizedBox(height: 8),
                  if (normalized != null && !canSave && _result != null && !_result!.ok)
                    TextButton(
                      onPressed: () => _save(skipTest: true),
                      child: const Text('Simpan tanpa tes koneksi'),
                    ),
                  if (ApiConfig.isConfigured)
                    TextButton(
                      onPressed: _reset,
                      child: const Text('Kembalikan ke bawaan'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _notice(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.3))),
      ]),
    );
  }
}
