import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// Enums & Models
// ─────────────────────────────────────────────────────────────────────────────

enum NetworkHealthTier { excellent, fair, poor, degraded }

class NetworkHealthStatus {
  const NetworkHealthStatus({
    required this.tier,
    required this.label,
    required this.summary,
    required this.idlePingMs,
    required this.downloadBandwidthMbps,
    required this.uploadBandwidthMbps,
    required this.packetLossPercent,
    required this.downloadPingMs,
    required this.uploadPingMs,
  });

  final NetworkHealthTier tier;
  final String label;
  final String summary;
  final int idlePingMs;
  final double downloadBandwidthMbps;
  final double uploadBandwidthMbps;
  final double packetLossPercent;
  final int downloadPingMs;
  final int uploadPingMs;

  double get averageBandwidth =>
      (downloadBandwidthMbps + uploadBandwidthMbps) / 2;

  String get adaptiveMode {
    switch (tier) {
      case NetworkHealthTier.excellent:
        return 'High-resolution media';
      case NetworkHealthTier.fair:
        return 'Balanced media flow';
      case NetworkHealthTier.poor:
        return 'Reduced-quality mode';
      case NetworkHealthTier.degraded:
        return 'Lightweight placeholders';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

class NetworkHealthProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();

  bool _isRunning = false;

  NetworkHealthStatus _status = const NetworkHealthStatus(
    tier: NetworkHealthTier.fair,
    label: 'Not tested yet',
    summary: 'Tap "Run Diagnostic" to measure your connection.',
    idlePingMs: 0,
    downloadBandwidthMbps: 0,
    uploadBandwidthMbps: 0,
    packetLossPercent: 0,
    downloadPingMs: 0,
    uploadPingMs: 0,
  );

  NetworkHealthStatus get current => _status;
  bool get isRunning => _isRunning;

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> runDiagnosticOnce() async {
    if (_isRunning) return;
    _isRunning = true;
    notifyListeners();

    try {
      _status = await _runDiagnosticCycle();
    } catch (_) {
      _status = _offlineStatus();
    } finally {
      _isRunning = false;
      notifyListeners();
    }
  }

  // ── Core diagnostic cycle ──────────────────────────────────────────────────

  Future<NetworkHealthStatus> _runDiagnosticCycle() async {
    // 1. Quick connectivity check via connectivity_plus
    final hasConnection = await _hasActiveConnection();
    if (!hasConnection) return _offlineStatus();

    // 2. Idle ping — HEAD request to a reliable host
    final idlePingMs = await _measurePing();
    if (idlePingMs < 0) return _offlineStatus();

    // 3. Packet-loss simulation — 6 pings, count failures
    final packetLoss = await _measurePacketLoss();

    // 4. Download bandwidth — fetch a small public file and time it
    final (downloadMs, downloadMbps) = await _measureDownload();

    // 5. Upload bandwidth — POST a small payload and time it
    final (uploadMs, uploadMbps) = await _measureUpload();

    return _evaluateHealth(
      idlePingMs: idlePingMs,
      downloadBandwidthMbps: downloadMbps,
      uploadBandwidthMbps: uploadMbps,
      packetLossPercent: packetLoss,
      downloadPingMs: downloadMs,
      uploadPingMs: uploadMs,
    );
  }

  // ── Connectivity check ─────────────────────────────────────────────────────

  Future<bool> _hasActiveConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  // ── Ping ──────────────────────────────────────────────────────────────────
  // Uses a HEAD request — tiny round-trip, no body downloaded.

  Future<int> _measurePing({String host = 'https://www.google.com'}) async {
    try {
      final sw = Stopwatch()..start();
      final response =
          await http.head(Uri.parse(host)).timeout(const Duration(seconds: 5));
      sw.stop();
      if (response.statusCode >= 200 && response.statusCode < 600) {
        return sw.elapsedMilliseconds;
      }
      return -1;
    } catch (_) {
      return -1;
    }
  }

  // ── Packet loss ───────────────────────────────────────────────────────────

  Future<double> _measurePacketLoss() async {
    const total = 6;
    var successes = 0;
    for (var i = 0; i < total; i++) {
      final ms = await _measurePing();
      if (ms > 0) successes++;
    }
    final lost = total - successes;
    return ((lost / total) * 100).clamp(0, 100).toDouble();
  }

  // ── Download bandwidth ────────────────────────────────────────────────────
  // Fetches a ~100 KB JSON from jsonplaceholder (always available, CORS-friendly).

  Future<(int pingMs, double mbps)> _measureDownload() async {
    // ~100 KB of JSON — 100 posts × ~500 bytes each
    final uri = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    try {
      final sw = Stopwatch()..start();
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      sw.stop();
      final bytes = response.bodyBytes.length;
      final secs = sw.elapsedMilliseconds / 1000.0;
      final mbps = (bytes * 8) / (secs * 1000000.0);
      return (
        sw.elapsedMilliseconds,
        mbps.clamp(0.0, double.infinity),
      );
    } catch (_) {
      return (0, 0.0);
    }
  }

  // ── Upload bandwidth ──────────────────────────────────────────────────────
  // POSTs ~50 KB to jsonplaceholder's /posts endpoint (free, no auth).

  Future<(int pingMs, double mbps)> _measureUpload() async {
    final uri = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    // Build ~50 KB payload
    final payload = List.generate(
      500,
      (i) =>
          '{"id":$i,"title":"test title $i","body":"body content for item $i used in upload speed test","userId":1}',
    ).join(',\n');

    try {
      final sw = Stopwatch()..start();
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: '[$payload]',
          )
          .timeout(const Duration(seconds: 15));
      sw.stop();
      final bytes = payload.length;
      final secs = sw.elapsedMilliseconds / 1000.0;
      final mbps = (bytes * 8) / (secs * 1000000.0);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return (
          sw.elapsedMilliseconds,
          mbps.clamp(0.0, double.infinity),
        );
      }
      return (sw.elapsedMilliseconds, 0.0);
    } catch (_) {
      return (0, 0.0);
    }
  }

  // ── Health evaluation ─────────────────────────────────────────────────────

  static NetworkHealthStatus _evaluateHealth({
    required int idlePingMs,
    required double downloadBandwidthMbps,
    required double uploadBandwidthMbps,
    required double packetLossPercent,
    required int downloadPingMs,
    required int uploadPingMs,
  }) {
    final avgLatency =
        ((idlePingMs + downloadPingMs + uploadPingMs) / 3).round();
    final avgBandwidth = (downloadBandwidthMbps + uploadBandwidthMbps) / 2;

    if (packetLossPercent >= 25 || avgLatency >= 450) {
      return NetworkHealthStatus(
        tier: NetworkHealthTier.degraded,
        label: 'Degraded',
        summary:
            'Heavy packet loss or extreme latency. Switching to lightweight placeholders.',
        idlePingMs: idlePingMs,
        downloadBandwidthMbps: downloadBandwidthMbps,
        uploadBandwidthMbps: uploadBandwidthMbps,
        packetLossPercent: packetLossPercent,
        downloadPingMs: downloadPingMs,
        uploadPingMs: uploadPingMs,
      );
    }

    if (avgBandwidth > 10 && avgLatency <= 120) {
      return NetworkHealthStatus(
        tier: NetworkHealthTier.excellent,
        label: 'Excellent',
        summary: 'Connection is excellent. High-resolution content enabled.',
        idlePingMs: idlePingMs,
        downloadBandwidthMbps: downloadBandwidthMbps,
        uploadBandwidthMbps: uploadBandwidthMbps,
        packetLossPercent: packetLossPercent,
        downloadPingMs: downloadPingMs,
        uploadPingMs: uploadPingMs,
      );
    }

    if (avgBandwidth >= 2) {
      return NetworkHealthStatus(
        tier: NetworkHealthTier.fair,
        label: 'Fair',
        summary: 'Network is usable with moderate performance trade-offs.',
        idlePingMs: idlePingMs,
        downloadBandwidthMbps: downloadBandwidthMbps,
        uploadBandwidthMbps: uploadBandwidthMbps,
        packetLossPercent: packetLossPercent,
        downloadPingMs: downloadPingMs,
        uploadPingMs: uploadPingMs,
      );
    }

    return NetworkHealthStatus(
      tier: NetworkHealthTier.poor,
      label: 'Poor',
      summary:
          'Bandwidth is limited. Compression and lightweight mode recommended.',
      idlePingMs: idlePingMs,
      downloadBandwidthMbps: downloadBandwidthMbps,
      uploadBandwidthMbps: uploadBandwidthMbps,
      packetLossPercent: packetLossPercent,
      downloadPingMs: downloadPingMs,
      uploadPingMs: uploadPingMs,
    );
  }

  static NetworkHealthStatus _offlineStatus() {
    return const NetworkHealthStatus(
      tier: NetworkHealthTier.degraded,
      label: 'No Internet',
      summary:
          'No internet connection detected. Connect to Wi‑Fi or mobile data to run the diagnostic.',
      idlePingMs: 0,
      downloadBandwidthMbps: 0,
      uploadBandwidthMbps: 0,
      packetLossPercent: 100,
      downloadPingMs: 0,
      uploadPingMs: 0,
    );
  }

  // Keep these public so the existing activity3_screen.dart static calls work
  static double calculatePacketLoss({
    required int totalPackets,
    required int successfulPackets,
  }) {
    if (totalPackets <= 0) return 0;
    final lost = totalPackets - successfulPackets;
    return ((lost / totalPackets) * 100).clamp(0, 100).toDouble();
  }

  static NetworkHealthStatus evaluateHealth({
    required int idlePingMs,
    required double downloadBandwidthMbps,
    required double uploadBandwidthMbps,
    required double packetLossPercent,
    required int downloadPingMs,
    required int uploadPingMs,
  }) =>
      _evaluateHealth(
        idlePingMs: idlePingMs,
        downloadBandwidthMbps: downloadBandwidthMbps,
        uploadBandwidthMbps: uploadBandwidthMbps,
        packetLossPercent: packetLossPercent,
        downloadPingMs: downloadPingMs,
        uploadPingMs: uploadPingMs,
      );

  static NetworkHealthStatus offlineStatus() => _offlineStatus();
}
