import 'package:flutter/material.dart';
import 'package:lokinet_mobile/src/utils/is_darkmode.dart';

class LokinetDivider extends StatelessWidget {
  /// When true the ornament is rendered with `-` endings instead of `+`.
  final bool minus;

  const LokinetDivider({Key key, this.minus = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color color = inDarkMode(context) ? Colors.white : Colors.black;
    final String ending = minus ? "-" : "+";
    final TextStyle endingStyle =
        TextStyle(color: color, fontSize: 30, fontWeight: FontWeight.w100);

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 15,
            child: Text(
              ending,
              textAlign: TextAlign.center,
              style: endingStyle,
            ),
          ),
          Expanded(
            child: Container(
                margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: color,
                  height: 0,
                )),
          ),
          SizedBox(
            width: 15,
            child: Text(
              ending,
              textAlign: TextAlign.center,
              style: endingStyle,
            ),
          ),
        ],
      ),
    );
  }
}
