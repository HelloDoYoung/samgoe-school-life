import 'package:flutter/material.dart';
import 'screens/QRScreen.dart';
import 'screens/LunchScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR 학생증 앱',
      routes: {
        '/': (context) => QRScreen(),
        '/lunch': (context) => LunchScreen(),
      },
      initialRoute: '/',
    );
  }
}