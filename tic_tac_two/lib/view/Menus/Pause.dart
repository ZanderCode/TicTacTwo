import 'package:flutter/material.dart';

class Pause extends StatelessWidget {
  const Pause({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 10, color: Colors.red),
          color: Colors.blue,
        ),
        child: Center(child: Text("pause")),
      ),
    );
  }
}
