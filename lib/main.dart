import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lokinet_lib/lokinet_lib.dart';
import 'package:lokinet_mobile/src/utils/is_dakmode.dart';
import 'package:lokinet_mobile/src/widget/lokinet_divider.dart';
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
      home: MyHomePage(title: 'Lokinet'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  Widget build(BuildContext context) {
    final key = new GlobalKey<ScaffoldState>();

    bool darkModeOn = inDarkMode(context);

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
  @override
  Widget build(BuildContext context) {
    final key = new GlobalKey<FormState>();
    final textInput = TextEditingController();

    bool darkModeOn = inDarkMode(context);
    Color color = darkModeOn ? Colors.white : Colors.black;

    return Form(
        key: key,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: color, width: 1, style: BorderStyle.solid),
                      shape: CircleBorder()),
                  onPressed: () async {
                    if (!key.currentState.validate()) {
                      return;
                    }
                    if (await LokinetLib.isRunning) {
                      await LokinetLib.disconnectFromLokinet();
                    } else {
                      String exitNode = textInput.value.text.trim();
                      if (exitNode == "") exitNode = "exit.loki";
                      final result = await LokinetLib.prepareConnection();
                      if (result)
                        LokinetLib.connectToLokinet(exitNode: exitNode);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Icon(
                      Icons.power_settings_new_outlined,
                      size: 60,
                      color: color,
                    ),
                  )),
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
                  controller: textInput,
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
              TextButton(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('Is this thing on?')),
                  onPressed: () async {
                    if (await LokinetLib.isRunning) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Yes!')));
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('No!')));
                    }
                  })
            ]));
  }
}
