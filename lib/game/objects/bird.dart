import 'package:flutter/material.dart';

class Bird extends StatelessWidget {
  const Bird({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/bird.gif',
      height: 30,
      width: 30,
    );
  }
}
