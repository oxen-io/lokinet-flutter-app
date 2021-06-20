import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lokinet_lib/lokinet_lib.dart';
import 'package:lokinet_mobile/src/utils/is_dakmode.dart';
import 'package:lokinet_mobile/src/widget/lokinet_divider.dart';
import 'package:lokinet_mobile/src/widget/lokinet_power_button.dart';
import 'package:lokinet_mobile/src/widget/themed_lokinet_logo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
        body: Container(
            color: darkModeOn ? Colors.black : Colors.white,
            child: Column(children: [ThemedLokinetLogo(), MyForm()])));
  }
}

// Create a Form widget.
class MyForm extends StatefulWidget {
  @override
  MyFormState createState() {
    return MyFormState();
  }
}

class MyFormState extends State<MyForm> {
  static final key = new GlobalKey<FormState>();
  Timer _timer;
  bool isConnected = false;
  final exitInput = TextEditingController();
  final dnsInput = TextEditingController();

  void _startTimer() {
    const halfSec = Duration(milliseconds: 50);
    _timer = Timer.periodic(halfSec, (Timer timer) async {
      await _updateLokinetStatus();
    });
  }

  Future _updateLokinetStatus() async {
    var _isConnected = await LokinetLib.isRunning;
    setState(() {
      isConnected = _isConnected;
    });
  }

  Future _cancelTimer() async {
    await _updateLokinetStatus();
    if (_timer != null) _timer.cancel();
  }

  Future toogleLokinet() async {
    if (!key.currentState.validate()) {
      return;
    }
    if (await LokinetLib.isRunning) {
      await LokinetLib.disconnectFromLokinet();
      await _cancelTimer();
    } else {
      final String exitNode = exitInput.value.text.trim();
      final String upstreamDNS = dnsInput.value.text.trim();
      final result = await LokinetLib.prepareConnection();
      if (result) LokinetLib.connectToLokinet(exitNode: exitNode, upstreamDNS: upstreamDNS);
      _startTimer();
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
          LokinetPowerButton(toogleLokinet),
          LokinetDivider(),
          Padding(
            padding: EdgeInsets.only(left: 45, right: 45),
            child:
              TextFormField(
                validator: (value) {
                  final trimmed = value.trim();
                  if (trimmed == "") return null;
                  if (trimmed == ".loki" || !trimmed.endsWith(".loki"))
                  return "Invalid exit node value";
                  return null;
                },
                controller: exitInput,
                cursorColor: color,
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
          Padding(
            padding: EdgeInsets.only(left: 45, right: 45),
            child:
              TextFormField(
                validator: (value) {
                  final trimmed = value.trim();
                  if (trimmed == "") return null;
                  RegExp re = RegExp(r'^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$');
                  if (!re.hasMatch(trimmed))
                    return "DNS server does not look like an IP";
                  return null;
                },
                controller: dnsInput,
                cursorColor: color,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: darkModeOn
                  ? Color.fromARGB(255, 35, 35, 35)
                  : Color.fromARGB(255, 226, 226, 226),
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: color),
                  labelText: 'UpstreamDNS'),
              ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              isConnected ? "Connected" : "Not Connected",
              style: TextStyle(color: color),
            ),
          )
        ],
      ),
    );
  }
}
