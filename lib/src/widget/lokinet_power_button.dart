import 'package:flutter/material.dart';
import 'package:lokinet_mobile/src/utils/is_darkmode.dart';

class LokinetPowerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isConnected;
  final bool isBusy;

  const LokinetPowerButton({
    Key key,
    @required this.onPressed,
    this.isConnected = false,
    this.isBusy = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color color = isConnected
        ? Colors.teal
        : inDarkMode(context)
            ? Colors.white
            : Colors.black;

    final Widget content = isBusy
        ? const SizedBox(
            height: 60,
            width: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          )
        : Icon(
            Icons.power_settings_new_outlined,
            size: 60,
            color: color,
          );

    return Semantics(
      button: true,
      label: 'Toggle Lokinet connection',
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1, style: BorderStyle.solid),
          shape: const CircleBorder(),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: content,
        ),
      ),
    );
  }
}
