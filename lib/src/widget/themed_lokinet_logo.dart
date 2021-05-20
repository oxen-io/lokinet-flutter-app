import 'package:flutter/material.dart';
import 'package:lokinet_mobile/src/utils/is_dakmode.dart';

class ThemedLokinetLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lokinetLogo = inDarkMode(context)
        ? "assets/images/Lokinet_Text_White.png"
        : "assets/images/Lokinet_Text_Black.png";

    return Padding(
      padding: EdgeInsets.all(50),
      child: Image.asset(
        lokinetLogo,
        width: MediaQuery.of(context).size.width * 0.60,
      ),
    );
  }
}
