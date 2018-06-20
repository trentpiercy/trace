import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage>{
  _confirmDeletePortfolio() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text("Delete Portfolio File?"),
          content: new Text("This cannot be undone."),
          actions: <Widget>[
            new FlatButton(onPressed: () async {
              await _deletePortfolio();
              Navigator.of(context).pop();
              }, child: new Text("Delete")),
            new FlatButton(onPressed: () => Navigator.of(context).pop(), child: new Text("Cancel"))
          ],
        );
      }
    );
  }

  Future<Null> _deletePortfolio() async {
    getApplicationDocumentsDirectory().then((Directory directory) {
      File jsonFile = new File(directory.path + "/portfolio.json");
      print("DELETING PORTFOLIO...");
      jsonFile.delete();
    });
  }

  _exportPortfolio() {
    TextEditingController _portfolioExportController = new TextEditingController();
    _portfolioExportController.text = portfolioMap.toString();
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) {
        return new Scaffold(
          appBar: new PreferredSize(
            preferredSize: const Size.fromHeight(appBarHeight),
            child: new AppBar(
              titleSpacing: 0.0,
              elevation: appBarElevation,
              title: new Text("Portfolio JSON"),
            ),
          ),
          body: new Container(
            padding: const EdgeInsets.all(8.0),
            child: new TextField(
              controller: _portfolioExportController,
              maxLines: 99,
            ),
          )
        );
      })
    );
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
                title: new Text("Delete portfolio file"),
                leading: new Icon(Icons.delete),
                onTap: _confirmDeletePortfolio,
              ),
            ),
            new Container(
              color: Theme.of(context).cardColor,
              child: new ListTile(
                title: new Text("Import portfolio JSON"),
                leading: new Icon(Icons.file_download),
                onTap: null,
              ),
            ),
            new Container(
              color: Theme.of(context).cardColor,
              child: new ListTile(
                title: new Text("Export portfolio JSON"),
                leading: new Icon(Icons.file_upload),
                onTap: _exportPortfolio,
              ),
            ),
          ],
        ),
    );
  }
}