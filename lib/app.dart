import 'package:flutter/material.dart';
import 'screens/home.dart';

class ConfirmeratorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Blockchain Notifications',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        primaryColor: Colors.orange,
        accentColor: Colors.orangeAccent
    ),
    home: Home(),
  );
}