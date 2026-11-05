import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokinet_mobile/main.dart';
import 'package:lokinet_mobile/src/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, String>{
      'exit-node': 'exit.loki',
      'upstream-dns': '9.9.9.9',
    });
    // The settings singleton is refreshed from the mock store on each run so
    // that the input controllers start with deterministic values.
    await Settings.getInstance().initialize();
  });

  testWidgets('renders the main ui', (WidgetTester tester) async {
    await tester.pumpWidget(const LokinetApp());

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.power_settings_new_outlined), findsOneWidget);
    expect(find.text('Exit Node'), findsOneWidget);
    expect(find.text('DNS'), findsOneWidget);
    expect(find.text('Not Connected'), findsOneWidget);
    expect(find.text('Connected'), findsNothing);
  });

  testWidgets('shows the saved exit node and dns values',
      (WidgetTester tester) async {
    await tester.pumpWidget(const LokinetApp());

    expect(find.widgetWithText(TextFormField, 'exit.loki'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '9.9.9.9'), findsOneWidget);
  });

  testWidgets('rejects an invalid exit node', (WidgetTester tester) async {
    await tester.pumpWidget(const LokinetApp());

    await tester.enterText(
        find.widgetWithText(TextFormField, 'exit.loki'), 'not-a-loki-address');
    await tester.tap(find.byIcon(Icons.power_settings_new_outlined));
    await tester.pump();

    expect(find.text('Invalid exit node value'), findsOneWidget);
    expect(find.text('Not Connected'), findsOneWidget);
  });

  testWidgets('rejects an invalid upstream dns', (WidgetTester tester) async {
    await tester.pumpWidget(const LokinetApp());

    await tester.enterText(
        find.widgetWithText(TextFormField, '9.9.9.9'), 'not-an-ip');
    await tester.tap(find.byIcon(Icons.power_settings_new_outlined));
    await tester.pump();

    expect(find.text('DNS server does not look like an IP'), findsOneWidget);
    expect(find.text('Not Connected'), findsOneWidget);
  });

  testWidgets('status text adapts to dark mode', (WidgetTester tester) async {
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.dark;
    addTearDown(
        tester.binding.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const LokinetApp());
    await tester.pumpAndSettle();

    final Text status = tester.widget<Text>(find.text('Not Connected'));
    expect(status.style.color, Colors.white);
  });

  testWidgets('status text adapts to light mode', (WidgetTester tester) async {
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.light;
    addTearDown(
        tester.binding.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const LokinetApp());
    await tester.pumpAndSettle();

    final Text status = tester.widget<Text>(find.text('Not Connected'));
    expect(status.style.color, Colors.black);
  });

  test('settings persist exit node and upstream dns', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final Settings settings = Settings.getInstance();

    settings.exitNode = 'somewhere.loki';
    settings.upstreamDNS = '1.1.1.1';

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('exit-node'), 'somewhere.loki');
    expect(preferences.getString('upstream-dns'), '1.1.1.1');
    expect(settings.exitNode, 'somewhere.loki');
    expect(settings.upstreamDNS, '1.1.1.1');
  });

  testWidgets('status page shows connection info and router status',
      (WidgetTester tester) async {
    const MethodChannel pathProviderChannel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestWidgetsFlutterBinding.ensureInitialized();
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (MethodCall call) async {
      return '/tmp/opencode/fake-docs';
    });

    await tester.pumpWidget(const LokinetApp());
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Not connected'), findsOneWidget);
    expect(find.text('exit.loki'), findsOneWidget);
    expect(find.text('9.9.9.9'), findsOneWidget);
    expect(find.text('Data directory'), findsOneWidget);
    expect(find.text('Router status'), findsOneWidget);
    expect(find.text('Unavailable (router not running).'), findsOneWidget);
  });
}
