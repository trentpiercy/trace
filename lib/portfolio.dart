import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

import 'main.dart';

class PortfolioPage extends StatefulWidget {
  PortfolioPage(this.toggleTheme);
  final toggleTheme;

  @override
  PortfolioPageState createState() => new PortfolioPageState();
}

class PortfolioPageState extends State<PortfolioPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: new PreferredSize(
        preferredSize: const Size.fromHeight(appBarHeight),
        child: new AppBar(
          titleSpacing: 0.0,
          elevation: appBarElevation,
          title: new Text("Portfolio"),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.timeline,
                  color: Theme.of(context).iconTheme.color),
              onPressed: null,
            )
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: null,
        elevation: appBarElevation,
        backgroundColor: Theme.of(context).buttonColor,
        child: new Icon(Icons.add, color: Theme.of(context).iconTheme.color),
      ),
      drawer: new Drawer(
        child: new Scaffold(
          bottomNavigationBar: new Container(
            decoration: new BoxDecoration(
              border: new Border(top: new BorderSide(color: Theme.of(context).dividerColor))
            ),
            child: new ListTile(
              onTap: widget.toggleTheme,
              leading: new Icon(darkEnabled ? Icons.brightness_3 : Icons.brightness_7, color: Theme.of(context).buttonColor),
              title: new Text(themeMode, style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).buttonColor)),
            )
          ),
          body: new ListView(
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.settings),
                title: new Text("Settings"),
              ),
            ],
          )
        )
      ),

      body: new Container(
        padding: const EdgeInsets.all(16.0),
        height: 200.0,
        child: null,
      ),
    );
  }
}