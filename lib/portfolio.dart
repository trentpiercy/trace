import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

import 'main.dart';

class PortfolioPage extends StatefulWidget {
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
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        height: 200.0,
        child: null,
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: null,
        elevation: appBarElevation,
        backgroundColor: Theme.of(context).buttonColor,
        child: new Icon(Icons.add, color: Theme.of(context).iconTheme.color),
      ),
    );
  }
}
