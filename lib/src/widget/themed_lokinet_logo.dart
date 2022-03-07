import 'package:flutter/material.dart';
import 'package:lokinet_mobile/src/utils/is_darkmode.dart';

class ThemedLokinetLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lokinetLogo = inDarkMode(context)
        ? "assets/images/Lokinet_Text_White.png"
        : "assets/images/Lokinet_Text_Black.png";

    return Padding(
      padding: EdgeInsets.only(top: 50, bottom: 30),
      child: Image.asset(
        lokinetLogo,
        width: MediaQuery.of(context).size.width * 0.60,
      ),
    );
  }
}
