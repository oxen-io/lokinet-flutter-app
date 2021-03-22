import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class LokinetLib {
  static const MethodChannel _channel =
      const MethodChannel('lokinet_lib');

  static Future bootstrapLokinet() async {
    final request = await HttpClient().getUrl(Uri.parse('https://seed.lokinet.org/lokinet.signed'));
    final response = await request.close();
    var path = await getApplicationDocumentsDirectory();
    await response.pipe(File('${path.parent.path}/files/bootstrap.signed').openWrite());
    print('${path.parent.path}/files/lokinet.signed');
    print(Directory('${path.parent.path}/files/').listSync().toString());
  }

  static Future<bool> prepareConnection() async {
    final bool prepare = await _channel.invokeMethod('prepare');
    return prepare;
  }

  static Future<bool> get isPrepare async {
    final bool prepared = await _channel.invokeMethod('prepared');
    return prepared;
  }

  static Future<bool> connectToLokinet() async {
    final bool connect = await _channel.invokeMethod('connect');
    return connect;
  }

  static Future<bool> disconnectFromLokinet() async {
    final bool disconnect = await _channel.invokeMethod('disconnect');
    return disconnect;
  }
}
