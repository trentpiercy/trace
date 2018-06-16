import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tabs.dart';
import 'package:trace/portfolio/portfolio_tabs.dart';
import 'settings_page.dart';

void main() {
  runApp(new TraceApp());
}

const double appBarHeight = 48.0;
const double appBarElevation = 1.0;

bool shortenOn = false;

List marketListData;
Map globalData;
Map portfolioMap;

numCommaParse(numString) {
  if (shortenOn) {
    String str = num.parse(numString).round().toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
    List<String> strList = str.split(",");

    if (strList.length > 3) {
      return "\$"+strList[0] + "." + strList[1].substring(0, 4-strList[0].length)+"B";
    } else if (str.length > 2) {
      return "\$"+strList[0] +"." + strList[1].substring(0, 4-strList[0].length)+"M";
    }
  }

  return "\$"+ num.parse(numString).round().toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
}

numCommaParseNoDollar(numString) {
  return num.parse(numString).round().toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
}

numCommaParseNoRound(numString) {
  return numString.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
}


class TraceApp extends StatefulWidget {
  @override
  TraceAppState createState() => new TraceAppState();
}

class TraceAppState extends State<TraceApp> {
  bool darkEnabled;
  String themeMode = "Automatic";


  void savePreferences() async {
    print("----- saving prefs");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("themeMode", themeMode);
    prefs.setBool("shortenOn", shortenOn);
  }

  void getPreferences() async {
    print("----- getting prefs");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("shortenOn") != null && prefs.getString("themeMode") != null) {
      shortenOn = prefs.getBool("shortenOn");
      themeMode = prefs.getString("themeMode");
      handleUpdate();
    }
  }

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
    savePreferences();
  }

  void handleUpdate() {
    switch (themeMode) {
      case "Automatic":
        int nowHour = new DateTime.now().hour;
        if (nowHour > 6 && nowHour < 20) {
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

//    textSelectionColor: Colors.black,
    textSelectionHandleColor: Colors.purple[700],
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

//    textSelectionColor: Colors.white,
    textSelectionHandleColor: Colors.deepPurpleAccent[100],
    buttonColor: Colors.deepPurpleAccent[100],
    iconTheme: new IconThemeData(color: Colors.white),
    accentIconTheme: new IconThemeData(color: Colors.deepPurpleAccent[100]),
    cardColor: Color.fromRGBO(55, 55, 55, 1.0),
    dividerColor: Color.fromRGBO(60, 60, 60, 1.0),
  );

  @override
  void initState() {
    super.initState();
    getPreferences();
    handleUpdate();
  }

  @override
  Widget build(BuildContext context) {
    print("BUILT MAIN APP ==========");

    return new MaterialApp(
      color: darkEnabled ? darkTheme.primaryColor : lightTheme.primaryColor,
      title: "Trace",
      home: new Tabs(toggleTheme, savePreferences, handleUpdate, darkEnabled, themeMode),
      theme: darkEnabled ? darkTheme : lightTheme,
      routes: <String, WidgetBuilder> {
        "/portfolioTimeline": (BuildContext context) => new PortfolioTabs(0),
        "/portfolioBreakdown": (BuildContext context) => new PortfolioTabs(1),
        "/settings": (BuildContext context) => new SettingsPage(),
      },
    );
  }
}