import 'package:flutter/material.dart';

import 'tabs.dart';

void main() {
  runApp(new TraceApp());
}

const double appBarHeight = 48.0;
const double appBarElevation = 1.0;

class TraceApp extends StatefulWidget {
  @override
  TraceAppState createState() => new TraceAppState();
}

class TraceAppState extends State<TraceApp> {
  bool darkEnabled;
  String themeMode = "Automatic"; //TODO: store this

  void toggleTheme() {
    switch (themeMode) {
      case "Automatic":
        themeMode = "Dark";
        break;
      case "Dark":
        themeMode = "Light";
        break;
      case "Light":
        themeMode = "Automatic";
        break;
    }
    handleUpdate();
  }

  void handleUpdate() {
    switch (themeMode) {
      case "Automatic":
        int nowHour = new DateTime.now().hour;
        if (nowHour > 6 && nowHour < 18) {
          darkEnabled = false;
        } else {
          darkEnabled = true;
        }
        break;
      case "Dark":
        darkEnabled = true;
        break;
      case "Light":
        darkEnabled = false;
        break;
    }
    setState(() {});
  }

  final ThemeData lightTheme = new ThemeData(
    primarySwatch: Colors.purple,

    brightness: Brightness.light,
    accentColor: Colors.purpleAccent[100],
    primaryColor: Colors.white,
    primaryColorLight: Colors.purple[700],

    textSelectionColor: Colors.grey[200],
    dividerColor: Colors.grey[200],
    buttonColor: Colors.purple[700],
    iconTheme: new IconThemeData(color: Colors.white),
    primaryIconTheme: new IconThemeData(color: Colors.black),
    accentIconTheme: new IconThemeData(color: Colors.purple[700]),
    disabledColor: Colors.grey[500],
  );

  final ThemeData darkTheme = new ThemeData(
    primarySwatch: Colors.purple,

    brightness: Brightness.dark,
    accentColor: Colors.deepPurpleAccent[100],
    primaryColor: Color.fromRGBO(50, 50, 60, 1.0),
    primaryColorLight: Colors.deepPurpleAccent[100],

    textSelectionColor: Colors.blueGrey[800],
    buttonColor: Colors.deepPurpleAccent[100],
    iconTheme: new IconThemeData(color: Colors.white),
    accentIconTheme: new IconThemeData(color: Colors.deepPurpleAccent[100]),
    cardColor: Color.fromRGBO(55, 55, 55, 1.0),
    dividerColor: Color.fromRGBO(60, 60, 60, 1.0),
  );

  @override
  void initState() {
    super.initState();
    handleUpdate();
  }

  @override
  Widget build(BuildContext context) {
    print("BUILT MAIN APP ==========");

    return new MaterialApp(
      color: darkEnabled ? darkTheme.primaryColor : lightTheme.primaryColor,
      title: "Trace",
      home: new Tabs(toggleTheme, handleUpdate, darkEnabled, themeMode),
      theme: darkEnabled ? darkTheme : lightTheme,
    );
  }
}