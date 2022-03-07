import 'package:flutter/material.dart';
import 'package:lokinet_mobile/src/utils/is_darkmode.dart';

class LokinetPowerButton extends StatelessWidget {
  final VoidCallback onPressed;

  LokinetPowerButton(this.onPressed);

  @override
  Widget build(BuildContext context) {
    final color = inDarkMode(context) ? Colors.white : Colors.black;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color, width: 1, style: BorderStyle.solid),
        shape: CircleBorder(),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Icon(
          Icons.power_settings_new_outlined,
          size: 60,
          color: color,
        ),
      ),
    );
  }
}
