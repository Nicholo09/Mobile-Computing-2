import 'package:flutter_test/flutter_test.dart';
import 'package:mc2_portfolio/providers/network_health_provider.dart';

void main() {
  group('Network health diagnostics', () {
    test('excellent network conditions are classified correctly', () {
      final result = NetworkHealthProvider.evaluateHealth(
        idlePingMs: 24,
        downloadBandwidthMbps: 15.4,
        uploadBandwidthMbps: 10.2,
        packetLossPercent: 2,
        downloadPingMs: 36,
        uploadPingMs: 44,
      );

      expect(result.tier, NetworkHealthTier.excellent);
      expect(result.label, 'Excellent');
    });

    test(
        'degraded network conditions are flagged when latency and packet loss are severe',
        () {
      final result = NetworkHealthProvider.evaluateHealth(
        idlePingMs: 420,
        downloadBandwidthMbps: 1.1,
        uploadBandwidthMbps: 0.5,
        packetLossPercent: 42,
        downloadPingMs: 520,
        uploadPingMs: 560,
      );

      expect(result.tier, NetworkHealthTier.degraded);
      expect(result.label, 'Degraded');
    });

    test('offline status is reported when there is no internet connection', () {
      final result = NetworkHealthProvider.offlineStatus();

      expect(result.label, 'No Internet');
      expect(result.summary,
          contains('Connect to Wi‑Fi or mobile data to run the diagnostic'));
      expect(result.downloadBandwidthMbps, 0);
      expect(result.uploadBandwidthMbps, 0);
    });

    test('packet loss is calculated from actual sample results', () {
      final packetLoss = NetworkHealthProvider.calculatePacketLoss(
        totalPackets: 8,
        successfulPackets: 6,
      );

      expect(packetLoss, 25.0);
    });
  });
}
