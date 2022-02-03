import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static Settings _instance;
  String _exitNode;
  String _upstreamDNS;

  Settings._();

  Future<void> initialize() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    this._exitNode = sharedPreferences.getString("exit-node");
    this._upstreamDNS = sharedPreferences.getString("upstream-dns");
  }

  String get exitNode => this._exitNode;

  set exitNode(String exitNode) {
    this._exitNode = exitNode;
    SharedPreferences.getInstance().then((sharedPreferences) =>
        sharedPreferences.setString("exit-node", exitNode));
  }

  String get upstreamDNS => this._upstreamDNS;

  set upstreamDNS(String upstreamDNS) {
    this._upstreamDNS = upstreamDNS;
    SharedPreferences.getInstance().then((sharedPreferences) =>
        sharedPreferences.setString("upstream-dns", upstreamDNS));
  }

  static Settings getInstance() {
    if (Settings._instance == null) {
      Settings._instance = new Settings._();
    }
    return Settings._instance;
  }
}
