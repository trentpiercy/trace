import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage(
      {this.savePreferences,
      this.toggleTheme,
      this.darkEnabled,
      this.themeMode,
      this.switchOLED,
      this.darkOLED});
  final Function savePreferences;
  final Function toggleTheme;
  final bool darkEnabled;
  final String themeMode;
  final Function switchOLED;
  final bool darkOLED;

  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  _confirmDeletePortfolio() {
    showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: new Text("Clear Portfolio?"),
            content: new Text("This will permanently delete all transactions."),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () async {
                    await _deletePortfolio();
                    Navigator.of(context).pop();
                  },
                  child: new Text("Delete")),
              new FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: new Text("Cancel"))
            ],
          );
        });
  }

  Future<Null> _deletePortfolio() async {
    getApplicationDocumentsDirectory().then((Directory directory) {
      File jsonFile = new File(directory.path + "/portfolio.json");
      jsonFile.delete();
      portfolioMap = {};
    });
  }

  _exportPortfolio() {
    String text = json.encode(portfolioMap);
    GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new Scaffold(
          key: _scaffoldKey,
          appBar: new PreferredSize(
            preferredSize: const Size.fromHeight(appBarHeight),
            child: new AppBar(
              titleSpacing: 0.0,
              elevation: appBarElevation,
              title: new Text("Export Portfolio"),
            ),
          ),
          body: new SingleChildScrollView(
              child: new InkWell(
              onTap: () {
                Clipboard.setData(new ClipboardData(text: text));
                _scaffoldKey.currentState.showSnackBar(new SnackBar(
                    backgroundColor: Theme.of(context).indicatorColor,
                    content: new Text("Copied to Clipboard!")));
            },
            child: new Container(
                padding: const EdgeInsets.all(10.0),
                child: new Text(text,
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .apply(fontSizeFactor: 1.1))),
          )));
    }));
  }

  _showImportPage() {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => new ImportPage()));
  }

  _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String version = "";
  String buildNumber = "";
  _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber; 
    });
  }

  void initState() { 
    super.initState();
    _getVersion();
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
            child: new Text("Preferences",
                style: Theme.of(context).textTheme.body2),
          ),
          new Container(
              color: Theme.of(context).cardColor,
              child: new ListTile(
                onTap: widget.toggleTheme,
                leading: new Icon(widget.darkEnabled
                    ? Icons.brightness_3
                    : Icons.brightness_7),
                subtitle: new Text(widget.themeMode),
                title: new Text("Theme"),
              )),
          new Container(
            color: Theme.of(context).cardColor,
            child: new ListTile(
              leading: new Icon(Icons.opacity),
              title: new Text("OLED Dark Mode"),
              trailing: new Switch(
                activeColor: Theme.of(context).accentColor,
                value: widget.darkOLED,
                onChanged: (onOff) {
                  widget.switchOLED(state: onOff);
                },
              ),
              onTap: widget.switchOLED,
            ),
          ),
          new Container(
            color: Theme.of(context).cardColor,
            child: new ListTile(
              leading: new Icon(Icons.short_text),
              title: new Text("Abbreviate Numbers"),
              trailing: new Switch(
                  activeColor: Theme.of(context).accentColor,
                  value: shortenOn,
                  onChanged: (onOff) {
                    setState(() {
                      shortenOn = onOff;
                    });
                    widget.savePreferences();
                  }),
              onTap: () {
                setState(() {
                  shortenOn = !shortenOn;
                });
                widget.savePreferences();
              },
            ),
          ),
          new Container(
            padding: const EdgeInsets.all(10.0),
            child: new Text("Debug", style: Theme.of(context).textTheme.body2),
          ),
          new Container(
            color: Theme.of(context).cardColor,
            child: new ListTile(
              title: new Text("Export Portfolio"),
              leading: new Icon(Icons.file_upload),
              onTap: _exportPortfolio,
            ),
          ),
          new Container(
            color: Theme.of(context).cardColor,
            child: new ListTile(
              title: new Text("Import Portfolio"),
              leading: new Icon(Icons.file_download),
              onTap: _showImportPage,
            ),
          ),
          new Container(
            color: Theme.of(context).cardColor,
            child: new ListTile(
              title: new Text("Clear Portfolio"),
              leading: new Icon(Icons.delete),
              onTap: _confirmDeletePortfolio,
            ),
          ),
          new Container(
            color: Theme.of(context).cardColor,
            child: new ListTile(
              title: new Text("Issues & Feature Requests"),
              leading: new Icon(Icons.bug_report),
              onTap: () =>
                  _launchUrl("https://github.com/trentpiercy/trace/issues"),
            ),
          ),
          new Container(
            color: Theme.of(context).cardColor,
            child: new ListTile(
              title: new Text("Version $version ($buildNumber)"),
              subtitle: new Text("github.com/trentpiercy/trace"),
              leading: new Icon(Icons.info_outline),
              onTap: () => _launchUrl("https://github.com/trentpiercy/trace"),
            ),
          ),
          new Container(
            padding: const EdgeInsets.all(10.0),
            child: new Text("Credit", style: Theme.of(context).textTheme.body2),
          ),
          new Container(
            color: Theme.of(context).cardColor,
            child: new ListTile(
              title: new RichText(
                text: new TextSpan(
                  text: "Maintained with love by ",
                  style: Theme.of(context).textTheme.subhead,
                  children: <TextSpan>[
                    TextSpan(text: "@TrentPiercy", style: Theme.of(context).textTheme.subhead
                      .apply(color: Theme.of(context).buttonColor, fontWeightDelta: 2))
                  ]
                )
              ),
              subtitle: new Text("twitter.com/trentpiercy"),
              leading: new Icon(Icons.favorite),
              onTap: () => _launchUrl("https://twitter.com/trentpiercy"),
            ),
          ),
        ],
      ),
    );
  }
}

class ImportPage extends StatefulWidget {
  @override
  ImportPageState createState() => new ImportPageState();
}

class ImportPageState extends State<ImportPage> {
  TextEditingController _importController = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Map<String, dynamic> newPortfolioMap;
  Color textColor = Colors.red;
  List validSymbols = [];

  _checkImport(text) {
    try {
      Map<String, dynamic> checkMap = json.decode(text);
      if (checkMap.isEmpty) {
        throw "failed at empty map";
      }
      for (String symbol in checkMap.keys) {
        if (!validSymbols.contains(symbol)) {
          throw "symbol not valid";
        }
      }
      for (List transactions in checkMap.values) {
        if (transactions.isEmpty) {
          throw "failed at emtpy transaction list";
        }
        for (Map transaction in transactions) {
          if ((transaction.keys.toList()..sort()).toString() !=
              ["exchange", "notes", "price_usd", "quantity", "time_epoch"]
                  .toString()) {
            throw "failed formatting check at transaction keys";
          }
          for (String K in transaction.keys) {
            if (K == "quantity" || K == "time_epoch" || K == "price_usd") {
              num.parse(transaction[K].toString());
            }
          }
        }
      }

      newPortfolioMap = checkMap;
      setState(() {
        textColor = Theme.of(context).textTheme.body1.color;
      });
    } catch (e) {
      print("Invalid JSON: $e");
      newPortfolioMap = null;
      setState(() {
        textColor = Colors.red;
      });
    }
  }

  _importPortfolio() {
    showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: new Text("Import Portfolio?"),
            content: new Text(
                "This will permanently overwrite current portfolio and transactions."),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () async {
                    portfolioMap = newPortfolioMap;
                    await getApplicationDocumentsDirectory()
                        .then((Directory directory) {
                      File jsonFile =
                          new File(directory.path + "/portfolio.json");
                      jsonFile.writeAsStringSync(json.encode(portfolioMap));
                    });
                    Navigator.of(context).pop();
                    _scaffoldKey.currentState.showSnackBar(
                        new SnackBar(content: new Text("Success!")));
                  },
                  child: new Text("Import")),
              new FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: new Text("Cancel"))
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    marketListData.forEach((coin) {
      validSymbols.add(coin["symbol"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new PreferredSize(
          preferredSize: const Size.fromHeight(appBarHeight),
          child: new AppBar(
            titleSpacing: 0.0,
            elevation: appBarElevation,
            title: new Text("Import Portfolio"),
          ),
        ),
        body: new SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              new Padding(
                    padding: EdgeInsets.only(top: 6.0),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new RaisedButton(
                    onPressed: () async {
                      String clipText = (await Clipboard.getData('text/plain')).text;
                      _importController.text = clipText;
                      _checkImport(clipText);
                    },
                    child: new Text("Paste",
                        style: Theme.of(context)
                            .textTheme
                            .body2
                            .apply(color: Theme.of(context).iconTheme.color)),
                  ),
                  new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                  ),
                  new RaisedButton(
                    onPressed: textColor != Colors.red ? _importPortfolio : null,
                    child: new Text("Import",
                        style: Theme.of(context)
                            .textTheme
                            .body2
                            .apply(color: Theme.of(context).iconTheme.color)),
                    color: Colors.green,
                  ),
                ],
              ),
              new Container(
                padding: const EdgeInsets.all(10.0),
                child: new TextField(
                  controller: _importController,
                  maxLines: null,
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .apply(color: textColor, fontSizeFactor: 1.1),
                  decoration: new InputDecoration(
                      focusedBorder: new OutlineInputBorder(
                          borderSide: new BorderSide(
                              color: Theme.of(context).accentColor,
                              width: 2.0)),
                      border: new OutlineInputBorder(),
                      hintText: "Enter Portfolio JSON"),
                  onChanged: _checkImport,
                ),
              ),
            ],
          ),
        ));
  }
}
