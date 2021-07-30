import 'package:flutter/material.dart';
import 'package:bop/version.dart';

class BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      color: Colors.blueGrey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Version " + VERSION,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.black54, fontFamily: "Roboto"),
          ),
        ],
      ),
    );
  }
}
