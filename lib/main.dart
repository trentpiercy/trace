import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'tabs.dart';
import 'settings_page.dart';

const double appBarHeight = 48.0;
const double appBarElevation = 1.0;

bool shortenOn = false;

List marketListData;
Map portfolioMap;
List portfolioDisplay;
Map totalPortfolioStats;

bool isIOS;
String upArrow = "⬆";
String downArrow = "⬇";

int lastUpdate;

Future<Null> getMarketData() async {
  int numberOfCoins = 1500;
  List tempMarketListData = [];

  Future<Null> _pullData(start, limit) async {
    var response = await http.get(
        Uri.encodeFull("https://api.coinmarketcap.com/v2/ticker/" +
            "?start=" +
            start.toString() +
            "&limit=" +
            limit.toString()),
        headers: {"Accept": "application/json"});

    Map rawMarketListData = new JsonDecoder().convert(response.body)["data"];
    tempMarketListData.addAll(rawMarketListData.values);
  }

  List<Future> futures = [];
  for (int i = 0; i <= numberOfCoins / 100 - 1; i++) {
    int start = i * 100 + 1;
    int limit = i * 100 + 100;
    futures.add(_pullData(start, limit));
  }
  await Future.wait(futures);

  marketListData = tempMarketListData;
  getApplicationDocumentsDirectory().then((Directory directory) async {
    File jsonFile = new File(directory.path + "/marketData.json");
    jsonFile.writeAsStringSync(json.encode(marketListData));
  });
  print("Got new market data.");
  lastUpdate = DateTime.now().millisecondsSinceEpoch;
}

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
    if (portfolioMap == null) {
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
  bool darkOLED = false;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool("shortenOn") != null &&
      prefs.getString("themeMode") != null) {
    shortenOn = prefs.getBool("shortenOn");
    themeMode = prefs.getString("themeMode");
    darkOLED = prefs.getBool("darkOLED");
  }

  runApp(new TraceApp(themeMode, darkOLED));
}

numCommaParse(numString) {
  if (shortenOn) {
    String str = num.parse(numString ?? "0").round().toString().replaceAllMapped(
        new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
    List<String> strList = str.split(",");

    if (strList.length > 3) {
      return strList[0] +
          "." +
          strList[1].substring(0, 4 - strList[0].length) +
          "B";
    } else if (strList.length > 2) {
      return strList[0] +
          "." +
          strList[1].substring(0, 4 - strList[0].length) +
          "M";
    } else {
      return num.parse(numString ?? "0").toString().replaceAllMapped(
          new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
    }
  }

  return num.parse(numString ?? "0").toString().replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
}

normalizeNum(num input) {
  if (input == null) {
    input = 0;}
  if (input >= 100000) {
    return numCommaParse(input.round().toString());
  } else if (input >= 1000) {
    return numCommaParse(input.toStringAsFixed(2));
  } else {
    return input.toStringAsFixed(6 - input.round().toString().length);
  }
}

normalizeNumNoCommas(num input) {
  if (input == null) {
    input = 0;}
  if (input >= 1000) {
    return input.toStringAsFixed(2);
  } else {
    return input.toStringAsFixed(6 - input.round().toString().length);
  }
}

class TraceApp extends StatefulWidget {
  TraceApp(this.themeMode, this.darkOLED);
  final themeMode;
  final darkOLED;

  @override
  TraceAppState createState() => new TraceAppState();
}

class TraceAppState extends State<TraceApp> {
  bool darkEnabled;
  String themeMode;
  bool darkOLED;

  void savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("themeMode", themeMode);
    prefs.setBool("shortenOn", shortenOn);
    prefs.setBool("darkOLED", darkOLED);
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

  setDarkEnabled() {
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
    setNavBarColor();
  }

  handleUpdate() {
    setState(() {
      setDarkEnabled();
    });
  }

  switchOLED({state}) {
    setState(() {
      darkOLED = state ?? !darkOLED;
    });
    setNavBarColor();
    savePreferences();
  }

  setNavBarColor() async {
    if (darkEnabled) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarColor:
              darkOLED ? darkThemeOLED.primaryColor : darkTheme.primaryColor));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: lightTheme.primaryColor));
    }
  }

  final ThemeData lightTheme = new ThemeData(
    primarySwatch: Colors.purple,
    brightness: Brightness.light,
    accentColor: Colors.purpleAccent[100],
    primaryColor: Colors.white,
    primaryColorLight: Colors.purple[700],
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
    primaryColor: Color.fromRGBO(50, 50, 57, 1.0),
    primaryColorLight: Colors.deepPurpleAccent[100],
    textSelectionHandleColor: Colors.deepPurpleAccent[100],
    buttonColor: Colors.deepPurpleAccent[100],
    iconTheme: new IconThemeData(color: Colors.white),
    accentIconTheme: new IconThemeData(color: Colors.deepPurpleAccent[100]),
    cardColor: Color.fromRGBO(55, 55, 55, 1.0),
    dividerColor: Color.fromRGBO(60, 60, 60, 1.0),
    bottomAppBarColor: Colors.black26,
  );

  final ThemeData darkThemeOLED = new ThemeData(
    brightness: Brightness.dark,
    accentColor: Colors.deepPurpleAccent[100],
    primaryColor: Color.fromRGBO(5, 5, 5, 1.0),
    backgroundColor: Colors.black,
    canvasColor: Colors.black,
    primaryColorLight: Colors.deepPurple[300],
    buttonColor: Colors.deepPurpleAccent[100],
    accentIconTheme: new IconThemeData(color: Colors.deepPurple[300]),
    cardColor: Color.fromRGBO(16, 16, 16, 1.0),
    dividerColor: Color.fromRGBO(20, 20, 20, 1.0),
    bottomAppBarColor: Color.fromRGBO(19, 19, 19, 1.0),
    dialogBackgroundColor: Colors.black,
    textSelectionHandleColor: Colors.deepPurpleAccent[100],
    iconTheme: new IconThemeData(color: Colors.white),
  );

  @override
  void initState() {
    super.initState();
    themeMode = widget.themeMode ?? "Automatic";
    darkOLED = widget.darkOLED ?? false;
    setDarkEnabled();
  }

  @override
  Widget build(BuildContext context) {
    isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      upArrow = "↑";
      downArrow = "↓";
    }

    return new MaterialApp(
      color: darkEnabled
          ? darkOLED ? darkThemeOLED.primaryColor : darkTheme.primaryColor
          : lightTheme.primaryColor,
      title: "Trace",
      home: new Tabs(
        savePreferences: savePreferences,
        toggleTheme: toggleTheme,
        handleUpdate: handleUpdate,
        darkEnabled: darkEnabled,
        themeMode: themeMode,
        switchOLED: switchOLED,
        darkOLED: darkOLED,
      ),
      theme: darkEnabled ? darkOLED ? darkThemeOLED : darkTheme : lightTheme,
      routes: <String, WidgetBuilder>{
        "/settings": (BuildContext context) => new SettingsPage(
              savePreferences: savePreferences,
              toggleTheme: toggleTheme,
              darkEnabled: darkEnabled,
              themeMode: themeMode,
              switchOLED: switchOLED,
              darkOLED: darkOLED,
            ),
      },
    );
  }
}
