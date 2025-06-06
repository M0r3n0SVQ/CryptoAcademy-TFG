import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("SplashScreen: Build method called!");
    return const Scaffold(
      backgroundColor: Colors.amber,
      body: Center(
        child: Text(
          'SPLASH SCREEN TEST',
          style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
          textDirection: TextDirection.ltr,
      ),
    ));
  }
}
