import 'package:flutter/material.dart';
import 'package:lokinet_mobile/src/utils/is_dakmode.dart';

class LokinetDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = inDarkMode(context) ? Colors.white : Colors.black;

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
      child: Row(
        children: [
          Text(
            "+",
            style: TextStyle(
                color: color, fontSize: 30, fontWeight: FontWeight.w100),
          ),
          Expanded(
            child: new Container(
                margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: color,
                  height: 0,
                )),
          ),
          Text(
            "+",
            style: TextStyle(
                color: color, fontSize: 30, fontWeight: FontWeight.w100),
          ),
        ],
      ),
    );
  }
}
