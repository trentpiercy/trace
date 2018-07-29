import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quick_actions/quick_actions.dart';

import 'tabs.dart';
import 'settings_page.dart';

const double appBarHeight = 48.0;
const double appBarElevation = 1.0;

bool shortenOn = false;

List marketListData;
Map portfolioMap;
List portfolioDisplay;
Map totalPortfolioStats;

void main() async {
  await getApplicationDocumentsDirectory().then((Directory directory) async {
    File jsonFile = new File(directory.path + "/portfolio.json");
    if (jsonFile.existsSync()) {
      portfolioMap = json.decode(jsonFile.readAsStringSync());
    } else {
      jsonFile.createSync();
      jsonFile.writeAsStringSync("{}");
      portfolioMap = {};
    }

    jsonFile = new File(directory.path + "/marketData.json");
    if (jsonFile.existsSync()) {
      marketListData = json.decode(jsonFile.readAsStringSync());
    } else {
      jsonFile.createSync();
      jsonFile.writeAsStringSync("[]");
      marketListData = [];
    }
  });

  String themeMode = "Automatic";
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool("shortenOn") != null && prefs.getString("themeMode") != null) {
    shortenOn = prefs.getBool("shortenOn");
    themeMode = prefs.getString("themeMode");
  }

  quickActions.setShortcutItems(<ShortcutItem>[
    new quickActions.ShortcutItem(type: 'search', localizedTitle: 'Search', icon: 'icon_search'),
    new quickActions.ShortcutItem(type: 'new_transaction', localizedTitle: 'New Transaction', icon: 'icon_new_transaction')
  ]);

  runApp(new TraceApp(themeMode));
}

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
  return numString.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
}

class TraceApp extends StatefulWidget {
  TraceApp(this.themeMode);
  final themeMode;

  @override
  TraceAppState createState() => new TraceAppState();
}

class TraceAppState extends State<TraceApp> {
  bool darkEnabled;
  String themeMode;

  void savePreferences() async {
    print("----- saving prefs");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("themeMode", themeMode);
    prefs.setBool("shortenOn", shortenOn);
  }

  toggleTheme() {
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

  setDarkMode() {
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
  }

  handleUpdate() {
    setState(() {
      setDarkMode();
    });
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
    bottomAppBarColor: Colors.grey[200],
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
    bottomAppBarColor: Colors.black26,
  );

  @override
  void initState() {
    super.initState();
    themeMode = widget.themeMode ?? "Automatic";
    setDarkMode();
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
        "/settings": (BuildContext context) => new SettingsPage(savePreferences: savePreferences),
      },
    );
  }
}