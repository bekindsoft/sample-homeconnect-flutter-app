import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final String text;
  const GradientBackground({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.pink.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
