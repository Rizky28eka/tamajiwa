import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;

enum ServerCheckStatus {
  /// Server Tamajiwa menjawab dengan benar.
  ok,

  /// Tidak bisa terhubung (alamat salah, server mati, tanpa internet, timeout).
  unreachable,

  /// Ada jawaban, tetapi bukan dari API Tamajiwa.
  notTamajiwa,

  /// Server menjawab dengan status galat.
  httpError,
}

class ServerCheckResult {
  final ServerCheckStatus status;
  final int? statusCode;
  const ServerCheckResult(this.status, {this.statusCode});

  bool get ok => status == ServerCheckStatus.ok;

  String get message {
    switch (status) {
      case ServerCheckStatus.ok:
        return 'Terhubung ke server Tamajiwa.';
      case ServerCheckStatus.unreachable:
        return 'Server tidak dapat dijangkau. Periksa alamat, koneksi, dan pastikan server menyala.';
      case ServerCheckStatus.notTamajiwa:
        return 'Alamat menjawab, tetapi bukan API Tamajiwa. Pastikan alamat berakhir dengan /api.';
      case ServerCheckStatus.httpError:
        return 'Server menjawab dengan galat ${statusCode ?? ''}. Periksa alamatnya.';
    }
  }
}

class ServerCheckService {
  /// Mengganti klien HTTP saat pengujian.
  @visibleForTesting
  static http.Client Function()? clientOverride;

  /// Menguji `GET {baseUrl}/health-check`. [client] bisa diganti saat pengujian.
  static Future<ServerCheckResult> check(
    String baseUrl, {
    http.Client? client,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final injected = client ?? clientOverride?.call();
    final c = injected ?? http.Client();
    try {
      final res = await c
          .get(Uri.parse('$baseUrl/health-check'),
              headers: const {'Accept': 'application/json'})
          .timeout(timeout);

      if (res.statusCode != 200) {
        return ServerCheckResult(ServerCheckStatus.httpError,
            statusCode: res.statusCode);
      }
      try {
        final body = json.decode(res.body);
        if (body is Map && body['status'] == 'OK') {
          return const ServerCheckResult(ServerCheckStatus.ok, statusCode: 200);
        }
      } catch (_) {}
      return const ServerCheckResult(ServerCheckStatus.notTamajiwa,
          statusCode: 200);
    } on TimeoutException {
      return const ServerCheckResult(ServerCheckStatus.unreachable);
    } catch (_) {
      return const ServerCheckResult(ServerCheckStatus.unreachable);
    } finally {
      if (injected == null) c.close();
    }
  }
}
