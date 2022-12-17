import 'package:flutter/material.dart';

class Enemy extends StatelessWidget {
  const Enemy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/redBird.gif',
      height: 30,
      width: 30,
    );
  }
}
