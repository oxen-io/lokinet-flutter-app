import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lokinet_lib/lokinet_lib.dart';
import 'package:lokinet_mobile/src/settings.dart';
import 'package:path_provider/path_provider.dart';

/// Shows the real connection state, the configuration the daemon uses, the
/// on-disk file locations and the raw router status dump.
class LokinetStatusPage extends StatefulWidget {
  const LokinetStatusPage({Key key}) : super(key: key);

  @override
  LokinetStatusPageState createState() => LokinetStatusPageState();
}

class LokinetStatusPageState extends State<LokinetStatusPage> {
  StreamSubscription<bool> _isConnectedEventSubscription;
  Directory _filesDir;
  bool _isBootstrapped = false;
  int _bootstrapSize = -1;
  dynamic _routerStatus;
  bool _statusFailed = false;
  bool _isDownloadingBootstrap = false;

  @override
  void initState() {
    super.initState();
    _isConnectedEventSubscription = LokinetLib.isConnectedEventStream
        .listen((bool isConnected) => setState(() {}));
    _loadFileInfo();
    _refreshStatus();
  }

  @override
  void dispose() {
    _isConnectedEventSubscription?.cancel();
    super.dispose();
  }

  String get _exitNodeInUse {
    final String exitNode = Settings.getInstance().exitNode;
    if (exitNode == null || exitNode.trim().isEmpty) {
      return 'exit.loki (default)';
    }
    return exitNode;
  }

  String get _upstreamDNSInUse {
    final String upstreamDNS = Settings.getInstance().upstreamDNS;
    if (upstreamDNS == null || upstreamDNS.trim().isEmpty) {
      return '9.9.9.9 (default)';
    }
    return upstreamDNS;
  }

  Future<void> _loadFileInfo() async {
    final Directory docsDir = await getApplicationDocumentsDirectory();
    final Directory filesDir = Directory('${docsDir.parent.path}/files');
    final File bootstrap = File('${filesDir.path}/bootstrap.signed');
    final bool exists = bootstrap.existsSync();
    setState(() {
      _filesDir = filesDir;
      _isBootstrapped = exists;
      _bootstrapSize = exists ? bootstrap.lengthSync() : -1;
    });
  }

  Future<void> _refreshStatus() async {
    try {
      final dynamic status = await LokinetLib.status;
      setState(() {
        _routerStatus = status;
        _statusFailed = false;
      });
    } catch (_) {
      setState(() {
        _statusFailed = true;
      });
    }
  }

  Future<void> _downloadBootstrap() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _isDownloadingBootstrap = true);
    try {
      await LokinetLib.bootstrapLokinet();
      await _loadFileInfo();
      messenger.showSnackBar(
          const SnackBar(content: Text('Bootstrap file downloaded.')));
    } catch (exception) {
      messenger.showSnackBar(SnackBar(
          content: Text('Downloading the bootstrap file failed: $exception')));
    } finally {
      if (mounted) {
        setState(() => _isDownloadingBootstrap = false);
      }
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 16, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String statusDump = _statusFailed
        ? 'Status query failed.'
        : _routerStatus == null
            ? 'Unavailable (router not running).'
            : const JsonEncoder.withIndent('  ').convert(_routerStatus);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              _loadFileInfo();
              _refreshStatus();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          _sectionTitle('Connection'),
          _row('State', LokinetLib.isConnected ? 'Connected' : 'Not connected'),
          _row('Exit node', _exitNodeInUse),
          _row('Upstream DNS', _upstreamDNSInUse),
          _sectionTitle('Files'),
          _row('Data directory', _filesDir == null ? '…' : _filesDir.path),
          _row('Config file', 'loki.network.loki.lokinet.ini'),
          _row('Bootstrap file',
              _isBootstrapped ? 'present ($_bootstrapSize bytes)' : 'missing'),
          if (!_isBootstrapped)
            Padding(
              padding: const EdgeInsets.all(8),
              child: OutlinedButton(
                onPressed: _isDownloadingBootstrap ? null : _downloadBootstrap,
                child: _isDownloadingBootstrap
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Download bootstrap file'),
              ),
            ),
          _sectionTitle('Router status'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: SelectableText(
              statusDump,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
