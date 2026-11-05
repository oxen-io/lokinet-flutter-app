import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lokinet_lib/lokinet_lib.dart';
import 'package:lokinet_mobile/src/settings.dart';
import 'package:lokinet_mobile/src/status_page.dart';
import 'package:lokinet_mobile/src/utils/is_darkmode.dart';
import 'package:lokinet_mobile/src/widget/lokinet_divider.dart';
import 'package:lokinet_mobile/src/widget/lokinet_power_button.dart';
import 'package:lokinet_mobile/src/widget/themed_lokinet_logo.dart';

void main() async {
  //Load settings
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.getInstance().initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const LokinetApp());
}

class LokinetApp extends StatelessWidget {
  const LokinetApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lokinet App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        // This makes the visual density adapt to the platform that you run the
        // app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LokinetHomePage(),
    );
  }
}

class LokinetHomePage extends StatelessWidget {
  const LokinetHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool darkModeOn = inDarkMode(context);

    return Scaffold(
      body: Container(
        color: darkModeOn ? Colors.black : Colors.white,
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) =>
                    SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const <Widget>[
                          ThemedLokinetLogo(),
                          MyForm(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Connection status',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            const LokinetStatusPage()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Create a Form widget.
class MyForm extends StatefulWidget {
  const MyForm({Key key}) : super(key: key);

  @override
  MyFormState createState() {
    return MyFormState();
  }
}

class MyFormState extends State<MyForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  StreamSubscription<bool> _isConnectedEventSubscription;
  TextEditingController _exitNodeInput;
  TextEditingController _upstreamDNSInput;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    final Settings settings = Settings.getInstance();
    _exitNodeInput = TextEditingController(text: settings.exitNode);
    _upstreamDNSInput = TextEditingController(text: settings.upstreamDNS);
    _isConnectedEventSubscription = LokinetLib.isConnectedEventStream
        .listen((bool isConnected) => setState(() {}));
  }

  @override
  void dispose() {
    _isConnectedEventSubscription?.cancel();
    _exitNodeInput.dispose();
    _upstreamDNSInput.dispose();
    super.dispose();
  }

  Future<void> toggleLokinet() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _isBusy = true);
    try {
      if (LokinetLib.isConnected) {
        await LokinetLib.disconnectFromLokinet();
      } else {
        //Save the exit node and upstream dns
        final Settings settings = Settings.getInstance();
        settings.exitNode = _exitNodeInput.text.trim();
        settings.upstreamDNS = _upstreamDNSInput.text.trim();

        final bool prepared = await LokinetLib.prepareConnection();
        if (!prepared) {
          messenger.showSnackBar(const SnackBar(
              content:
                  Text('Lokinet was not allowed to set up a VPN connection.')));
          return;
        }

        final bool connected = await LokinetLib.connectToLokinet(
            exitNode: settings.exitNode, upstreamDNS: settings.upstreamDNS);
        if (!connected) {
          messenger.showSnackBar(
              const SnackBar(content: Text('Could not connect to Lokinet.')));
        }
      }
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Lokinet error: $error')));
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  static String validateExitNode(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed == '.loki' || !trimmed.endsWith('.loki')) {
      return 'Invalid exit node value';
    }
    return null;
  }

  static String validateUpstreamDNS(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final RegExp re = RegExp(
        r'^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$');
    if (!re.hasMatch(trimmed)) {
      return 'DNS server does not look like an IP';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool darkModeOn = inDarkMode(context);
    final Color color = darkModeOn ? Colors.white : Colors.black;
    final bool isConnected = LokinetLib.isConnected;
    final bool fieldsEnabled = !isConnected && !_isBusy;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          LokinetPowerButton(
            onPressed: _isBusy ? null : toggleLokinet,
            isConnected: isConnected,
            isBusy: _isBusy,
          ),
          const LokinetDivider(),
          Padding(
            padding: const EdgeInsets.only(left: 45, right: 45),
            child: TextFormField(
              enabled: fieldsEnabled,
              validator: validateExitNode,
              controller: _exitNodeInput,
              cursorColor: color,
              style: TextStyle(color: color),
              decoration: InputDecoration(
                  filled: true,
                  fillColor: darkModeOn
                      ? const Color.fromARGB(255, 35, 35, 35)
                      : const Color.fromARGB(255, 226, 226, 226),
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: color),
                  labelText: 'Exit Node'),
            ),
          ),
          const LokinetDivider(minus: true),
          Padding(
            padding: const EdgeInsets.only(left: 45, right: 45),
            child: TextFormField(
              enabled: fieldsEnabled,
              validator: validateUpstreamDNS,
              controller: _upstreamDNSInput,
              cursorColor: color,
              style: TextStyle(color: color),
              decoration: InputDecoration(
                  filled: true,
                  fillColor: darkModeOn
                      ? const Color.fromARGB(255, 35, 35, 35)
                      : const Color.fromARGB(255, 226, 226, 226),
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: color),
                  labelText: 'DNS'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              isConnected ? 'Connected' : 'Not Connected',
              style: TextStyle(
                color: isConnected ? Colors.teal : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
