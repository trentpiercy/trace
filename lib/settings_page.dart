import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage>{
  _clearPortfolio() {
    getApplicationDocumentsDirectory().then((Directory directory) {
      File jsonFile = new File(directory.path + "/portfolio.json");
      print("WIPING PORTFOLIO...");
      jsonFile.writeAsStringSync("[]");
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new PreferredSize(
          preferredSize: const Size.fromHeight(appBarHeight),
          child: new AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            titleSpacing: 0.0,
            elevation: appBarElevation,
            title: new Text("Settings", style: Theme.of(context).textTheme.title),
          ),
        ),
        body: new ListView(
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(10.0),
              child: new Text("Debug", style: Theme.of(context).textTheme.body2),
            ),
            new Container(
              color: Theme.of(context).cardColor,
              child: new ListTile(
                title: new Text("Clear portfolio"),
                leading: new Icon(Icons.delete),
                onTap: _clearPortfolio,
              ),
            ),
          ],
        ),
    );
  }
}