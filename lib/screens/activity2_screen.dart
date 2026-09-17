import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Activity2Screen extends StatefulWidget {
  const Activity2Screen({super.key});

  @override
  State<Activity2Screen> createState() => _Activity2ScreenState();
}

class _QueuedRequest {
  _QueuedRequest({
    required this.id,
    required this.label,
    required this.status,
  });

  final int id;
  final String label;
  String status;
}

class _Activity2ScreenState extends State<Activity2Screen> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  List<ConnectivityResult> _connectionState = const [ConnectivityResult.none];
  final List<_QueuedRequest> _queuedRequests = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startConnectionListener();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _startConnectionListener() async {
    try {
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _handleConnectivityChange,
      );

      final current = await _connectivity.checkConnectivity();
      _handleConnectivityChange(current);
    } on MissingPluginException {
      setState(() {
        _connectionState = const [ConnectivityResult.wifi];
      });
    } catch (_) {
      setState(() {
        _connectionState = const [ConnectivityResult.none];
      });
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final nextState = results.isEmpty ? [ConnectivityResult.none] : results;
    if (!mounted) return;

    setState(() {
      _connectionState = nextState;
    });

    _processQueue();
  }

  bool get _hasStableConnection {
    if (_connectionState.isEmpty) {
      return false;
    }

    final active = _connectionState.first;
    return active == ConnectivityResult.wifi ||
        active == ConnectivityResult.mobile ||
        active == ConnectivityResult.ethernet ||
        active == ConnectivityResult.vpn;
  }

  String get _networkLabel {
    final active = _connectionState.isNotEmpty
        ? _connectionState.first
        : ConnectivityResult.none;

    switch (active) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Cellular';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
      default:
        return 'Offline';
    }
  }

  Future<void> _queueRequest() async {
    final request = _QueuedRequest(
      id: DateTime.now().millisecondsSinceEpoch,
      label: 'Large dataset #${_queuedRequests.length + 1}',
      status: 'Queued',
    );

    setState(() {
      _queuedRequests.insert(0, request);
    });

    await _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _queuedRequests.isEmpty) {
      return;
    }

    if (!_hasStableConnection) {
      final pending = _queuedRequests.where(
        (request) => request.status != 'Completed',
      );

      for (final request in pending) {
        if (request.status != 'Retrying') {
          setState(() {
            request.status = 'Queued';
          });
        }
      }
      return;
    }

    final nextRequest = _queuedRequests.firstWhere(
      (request) => request.status != 'Completed',
      orElse: () => _QueuedRequest(
        id: 0,
        label: 'No requests',
        status: 'Completed',
      ),
    );

    if (nextRequest.id == 0) {
      return;
    }

    _isProcessing = true;
    setState(() {
      nextRequest.status = 'Running';
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (!_hasStableConnection) {
        throw Exception('Connection lost during handover');
      }

      setState(() {
        nextRequest.status = 'Completed';
      });
    } catch (_) {
      setState(() {
        nextRequest.status = 'Retrying';
      });
    } finally {
      _isProcessing = false;
      if (_queuedRequests.any(
        (request) => request.status == 'Retrying' || request.status == 'Queued',
      )) {
        Future.microtask(_processQueue);
      }
    }
  }

  String get connectionStatusText {
    if (_connectionState.first == ConnectivityResult.none) {
      return 'Offline';
    }
    if (_hasStableConnection) {
      return 'Stable';
    }
    return 'Reconnecting';
  }

  Color _connectionColor() {
    if (_connectionState.first == ConnectivityResult.none) {
      return Colors.red;
    }
    if (_hasStableConnection) {
      return Colors.green;
    }
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 2'),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Network Monitor',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _connectionColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Network',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _networkLabel,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(
                        connectionStatusText,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor:
                          _connectionState.first == ConnectivityResult.none
                              ? Colors.red.shade100
                              : _hasStableConnection
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _queueRequest,
                  icon: const Icon(Icons.cloud_download_rounded),
                  label: const Text('Start Request'),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Queued Requests',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (_queuedRequests.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: const Text('No network requests queued yet.'),
                )
              else
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _queuedRequests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final request = _queuedRequests[index];
                    final statusColor = request.status == 'Completed'
                        ? Colors.green
                        : request.status == 'Running'
                            ? Colors.blue
                            : request.status == 'Retrying'
                                ? Colors.orange
                                : request.status == 'Queued'
                                    ? Colors.grey
                                    : Colors.grey;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Request #${request.id}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(28),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              request.status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
