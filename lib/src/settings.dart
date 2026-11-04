import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static Settings _instance;
  String _exitNode;
  String _upstreamDNS;

  Settings._();

  Future<void> initialize() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _exitNode = sharedPreferences.getString("exit-node");
    _upstreamDNS = sharedPreferences.getString("upstream-dns");
  }

  String get exitNode => _exitNode;

  set exitNode(String exitNode) {
    _exitNode = exitNode;
    SharedPreferences.getInstance().then((sharedPreferences) =>
        sharedPreferences.setString("exit-node", exitNode));
  }

  String get upstreamDNS => _upstreamDNS;

  set upstreamDNS(String upstreamDNS) {
    _upstreamDNS = upstreamDNS;
    SharedPreferences.getInstance().then((sharedPreferences) =>
        sharedPreferences.setString("upstream-dns", upstreamDNS));
  }

  static Settings getInstance() {
    return Settings._instance ??= Settings._();
  }
}
