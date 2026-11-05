import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class LokinetLib {
  static const MethodChannel _methodChannel =
      MethodChannel('lokinet_lib_method_channel');

  static const EventChannel _isConnectedEventChannel =
      EventChannel('lokinet_lib_is_connected_event_channel');

  static bool _isConnected = false;

  static bool get isConnected => _isConnected;

  static final Stream<bool> _isConnectedEventStream = _isConnectedEventChannel
      .receiveBroadcastStream()
      .cast<bool>()
    ..listen((dynamic newIsConnected) => _isConnected = newIsConnected);

  static Stream<bool> get isConnectedEventStream => _isConnectedEventStream;

  static Future<void> bootstrapLokinet() async {
    final HttpClient client = HttpClient();
    try {
      final request = await client
          .getUrl(Uri.parse('https://seed.lokinet.org/lokinet.signed'))
          .timeout(const Duration(seconds: 20));
      final response =
          await request.close().timeout(const Duration(seconds: 60));
      var path = await getApplicationDocumentsDirectory();
      await response
          .pipe(File('${path.parent.path}/files/bootstrap.signed').openWrite());
      if (await isBootstrapped) {
        debugPrint("Successfully bootstrapped!");
      } else {
        debugPrint("Bootstrapping went wrong!");
        debugPrint(
            Directory('${path.parent.path}/files/').listSync().toString());
      }
    } finally {
      client.close(force: true);
    }
  }

  static Future<bool> prepareConnection() async {
    if (!(await isBootstrapped)) await bootstrapLokinet();
    final bool prepare = await _methodChannel.invokeMethod('prepare');
    return prepare;
  }

  static Future<bool> connectToLokinet(
      {String exitNode = "exit.loki", String upstreamDNS = "9.9.9.9"}) async {
    final bool connect = await _methodChannel.invokeMethod(
        'connect', {"exit_node": exitNode, "upstream_dns": upstreamDNS});
    return connect;
  }

  static Future<bool> disconnectFromLokinet() async {
    final bool disconnect = await _methodChannel.invokeMethod('disconnect');
    return disconnect;
  }

  static Future<bool> get isPrepared async {
    final bool prepared = await _methodChannel.invokeMethod('isPrepared');
    return prepared;
  }

  static Future<bool> get isRunning async {
    final bool isRunning = await _methodChannel.invokeMethod('isRunning');
    return isRunning;
  }

  static Future<bool> get isBootstrapped async {
    var path = await getApplicationDocumentsDirectory();
    return File('${path.parent.path}/files/bootstrap.signed').existsSync();
  }

  static Future<dynamic> get status async {
    final dynamic status = await _methodChannel.invokeMethod('getStatus');
    if (status is String && status.isNotEmpty) return jsonDecode(status);
    return null;
  }
}
