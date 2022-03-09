import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lokinet_lib/lokinet_lib.dart';
import 'package:lokinet_mobile/src/settings.dart';
import 'package:lokinet_mobile/src/utils/is_darkmode.dart';
import 'package:lokinet_mobile/src/widget/lokinet_divider.dart';
import 'package:lokinet_mobile/src/widget/lokinet_power_button.dart';
import 'package:lokinet_mobile/src/widget/themed_lokinet_logo.dart';

void main() async {
  //Load settings
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.getInstance().initialize();

  runApp(LokinetApp());
}

class LokinetApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Lokinet App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.teal,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LokinetHomePage(),
    );
  }
}

class LokinetHomePage extends StatefulWidget {
  LokinetHomePage({Key key}) : super(key: key);

  @override
  LokinetHomePageState createState() => LokinetHomePageState();
}

class LokinetHomePageState extends State<LokinetHomePage> {
  Widget build(BuildContext context) {
    final key = new GlobalKey<ScaffoldState>();

    final bool darkModeOn = inDarkMode(context);

    return Scaffold(
        key: key,
        resizeToAvoidBottomInset:
            false, //Prevents overflow when keyboard is shown
        body: Container(
            color: darkModeOn ? Colors.black : Colors.white,
            child: Column(children: [ThemedLokinetLogo(), MyForm()])));
  }
}

final exitInput = TextEditingController(text: Settings.getInstance().exitNode);
final dnsInput =
    TextEditingController(text: Settings.getInstance().upstreamDNS);

// Create a Form widget.
class MyForm extends StatefulWidget {
  @override
  MyFormState createState() {
    return MyFormState();
  }
}

class MyFormState extends State<MyForm> {
  static final key = new GlobalKey<FormState>();
  StreamSubscription<bool> _isConnectedEventSubscription;

  @override
  initState() {
    super.initState();
    _isConnectedEventSubscription = LokinetLib.isConnectedEventStream
        .listen((bool isConnected) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _isConnectedEventSubscription?.cancel();
  }

  Future toggleLokinet() async {
    if (!key.currentState.validate()) {
      return;
    }
    if (LokinetLib.isConnected) {
      await LokinetLib.disconnectFromLokinet();
    } else {
      //Save the exit node and upstream dns
      final Settings settings = Settings.getInstance();
      settings.exitNode = exitInput.value.text.trim();
      settings.upstreamDNS = dnsInput.value.text.trim();

      final result = await LokinetLib.prepareConnection();
      if (result)
        LokinetLib.connectToLokinet(
            exitNode: settings.exitNode, upstreamDNS: settings.upstreamDNS);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkModeOn = inDarkMode(context);
    Color color = darkModeOn ? Colors.white : Colors.black;

    return Form(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          LokinetPowerButton(toggleLokinet),
          LokinetDivider(),
          Padding(
            padding: EdgeInsets.only(left: 45, right: 45),
            child: TextFormField(
              validator: (value) {
                final trimmed = value.trim();
                if (trimmed == "") return null;
                if (trimmed == ".loki" || !trimmed.endsWith(".loki"))
                  return "Invalid exit node value";
                return null;
              },
              controller: exitInput,
              cursorColor: color,
              style: TextStyle(color: color),
              decoration: InputDecoration(
                  filled: true,
                  fillColor: darkModeOn
                      ? Color.fromARGB(255, 35, 35, 35)
                      : Color.fromARGB(255, 226, 226, 226),
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: color),
                  labelText: 'Exit Node'),
            ),
          ),
          LokinetDivider(minus: true),
          Padding(
            padding: EdgeInsets.only(left: 45, right: 45),
            child: TextFormField(
              validator: (value) {
                final trimmed = value.trim();
                if (trimmed == "") return null;
                RegExp re = RegExp(
                    r'^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$');
                if (!re.hasMatch(trimmed))
                  return "DNS server does not look like an IP";
                return null;
              },
              controller: dnsInput,
              cursorColor: color,
              style: TextStyle(color: color),
              decoration: InputDecoration(
                  filled: true,
                  fillColor: darkModeOn
                      ? Color.fromARGB(255, 35, 35, 35)
                      : Color.fromARGB(255, 226, 226, 226),
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: color),
                  labelText: 'DNS'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              LokinetLib.isConnected ? "Connected" : "Not Connected",
              style: TextStyle(color: color),
            ),
          ),
          // TextButton(
          //     onPressed: () async {
          //       log((await LokinetLib.status).toString());
          //     },
          //     child: Text("Test"))
        ],
      ),
    );
  }
}
