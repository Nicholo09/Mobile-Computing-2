import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/network_health_provider.dart';

class Activity3Screen extends StatelessWidget {
  const Activity3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkHealthProvider>();
    final health = provider.current;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color statusColor = switch (health.tier) {
      NetworkHealthTier.excellent => const Color(0xFF2E7D32),
      NetworkHealthTier.fair => const Color(0xFFF57F17),
      NetworkHealthTier.poor => Colors.amber.shade700,
      NetworkHealthTier.degraded => const Color(0xFFB71C1C),
    };

    final IconData statusIcon = switch (health.tier) {
      NetworkHealthTier.excellent => Icons.signal_wifi_4_bar,
      NetworkHealthTier.fair => Icons.network_wifi_2_bar,
      NetworkHealthTier.poor => Icons.network_wifi_1_bar,
      NetworkHealthTier.degraded => Icons.wifi_off,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 3'),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ────────────────────────────────────────────
              Text(
                'Network Diagnostic Dashboard',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // ── Health Banner ─────────────────────────────────────
              _card(
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connection Health',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color:
                                    theme.colorScheme.onSurface.withAlpha(140),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              health.label,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              health.summary,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    theme.colorScheme.onSurface.withAlpha(160),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const SizedBox(height: 16),

              // ── Run button ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: provider.isRunning
                      ? null
                      : () => provider.runDiagnosticOnce(),
                  icon: provider.isRunning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(provider.isRunning
                      ? 'Running Diagnostic…'
                      : 'Run Diagnostic'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    disabledBackgroundColor:
                        const Color(0xFF2E7D32).withAlpha(120),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              // ── Offline warning ───────────────────────────────────
              if (health.label == 'No Internet') ...[
                const SizedBox(height: 12),
                _card(
                  isDark: isDark,
                  borderColor: const Color(0xFFB71C1C),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off,
                            color: Color(0xFFB71C1C), size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No internet connection detected. Connect to Wi-Fi or mobile data and try again.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB71C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // ── Running step list ─────────────────────────────────
              if (provider.isRunning) ...[
                const SizedBox(height: 16),
                _card(
                  isDark: isDark,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Diagnostic Steps',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 12),
                        ..._steps.map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(s, style: theme.textTheme.bodySmall),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],

              // ── Metric cards ──────────────────────────────────────
              if (health.label != 'Not tested yet' && !provider.isRunning) ...[
                const SizedBox(height: 20),
                Text('Measurements',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _MetricCard(
                  isDark: isDark,
                  title: 'Idle Ping',
                  value: health.idlePingMs > 0
                      ? '${health.idlePingMs} ms'
                      : '— ms',
                  icon: Icons.network_check,
                  rating: _pingRating(health.idlePingMs),
                ),
                const SizedBox(height: 10),
                _MetricCard(
                  isDark: isDark,
                  title: 'Download Speed',
                  value:
                      '${health.downloadBandwidthMbps.toStringAsFixed(2)} Mbps',
                  icon: Icons.download,
                  rating: _bandwidthRating(health.downloadBandwidthMbps),
                ),
                const SizedBox(height: 10),
                _MetricCard(
                  isDark: isDark,
                  title: 'Upload Speed',
                  value:
                      '${health.uploadBandwidthMbps.toStringAsFixed(2)} Mbps',
                  icon: Icons.upload,
                  rating: _bandwidthRating(health.uploadBandwidthMbps),
                ),
                const SizedBox(height: 10),
                _MetricCard(
                  isDark: isDark,
                  title: 'Loaded Latency',
                  value:
                      '${math.max(health.downloadPingMs, health.uploadPingMs)} ms',
                  icon: Icons.speed,
                  rating: _pingRating(
                      math.max(health.downloadPingMs, health.uploadPingMs)),
                ),
                const SizedBox(height: 10),
                _MetricCard(
                  isDark: isDark,
                  title: 'Packet Loss',
                  value: '${health.packetLossPercent.toStringAsFixed(1)} %',
                  icon: Icons.error_outline,
                  rating: _packetLossRating(health.packetLossPercent),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  static const _steps = [
    'Checking connectivity…',
    'Measuring idle ping (6 samples)…',
    'Measuring packet loss…',
    'Downloading test payload…',
    'Uploading test payload…',
    'Evaluating health score…',
  ];

  // Rating helpers — returns (label, color)
  static (String, Color) _pingRating(int ms) {
    if (ms <= 0) return ('N/A', Colors.grey);
    if (ms <= 80) return ('Excellent', const Color(0xFF2E7D32));
    if (ms <= 200) return ('Good', const Color(0xFFF57F17));
    if (ms <= 400) return ('Poor', Colors.amber.shade700);
    return ('Bad', const Color(0xFFB71C1C));
  }

  static (String, Color) _bandwidthRating(double mbps) {
    if (mbps <= 0) return ('N/A', Colors.grey);
    if (mbps >= 10) return ('Excellent', const Color(0xFF2E7D32));
    if (mbps >= 2) return ('Good', const Color(0xFFF57F17));
    if (mbps >= 0.5) return ('Poor', Colors.amber.shade700);
    return ('Bad', const Color(0xFFB71C1C));
  }

  static (String, Color) _packetLossRating(double pct) {
    if (pct <= 0) return ('None', const Color(0xFF2E7D32));
    if (pct < 5) return ('Low', const Color(0xFFF57F17));
    if (pct < 25) return ('High', Colors.amber.shade700);
    return ('Critical', const Color(0xFFB71C1C));
  }

  static Widget _card({
    required bool isDark,
    required Widget child,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ??
              (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E8E0)),
        ),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metric Card
// ─────────────────────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.rating,
    required this.isDark,
  });

  final String title;
  final String value;
  final IconData icon;
  final (String, Color) rating;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (ratingLabel, ratingColor) = rating;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E8E0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(140),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ratingColor.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ratingColor.withAlpha(80)),
            ),
            child: Text(
              ratingLabel,
              style: TextStyle(
                color: ratingColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
