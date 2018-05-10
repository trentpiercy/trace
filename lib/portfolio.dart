import 'package:flutter/material.dart';

import 'main.dart';

class PortfolioPage extends StatefulWidget {
  PortfolioPage(
    this.toggleTheme,
    this.darkEnabled,
    this.themeMode,
  );

  final toggleTheme;
  final darkEnabled;
  final themeMode;

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
              border: new Border(
                top: new BorderSide(color: Theme.of(context).dividerColor),
                bottom: new BorderSide(color: Theme.of(context).dividerColor)
              )
            ),
            child: new ListTile(
              onTap: widget.toggleTheme,
              leading: new Icon(widget.darkEnabled ? Icons.brightness_3 : Icons.brightness_7, color: Theme.of(context).buttonColor),
              title: new Text(widget.themeMode, style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).buttonColor)),
            )
          ),
          body: new ListView(
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.settings),
                title: new Text("Settings"),
              ),
              new ListTile(
                leading: new Icon(Icons.timeline),
                title: new Text("Portfolio Timeline"),
              ),
              new ListTile(
                leading: new Icon(Icons.short_text),
                title: new Text("Shorten Numbers"),
              )
            ],
          )
        )
      ),

      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            floating: true,
            pinned: false,

            backgroundColor: Theme.of(context).cardColor,

            title: new Text("Testing"),
            elevation: 0.0,
//            leading: new IconButton(icon: new Icon(Icons.search), onPressed: null),
            titleSpacing: 0.0,

          ),

          new SliverAppBar(
            backgroundColor: Theme.of(context).cardColor,
            elevation: appBarElevation,
            pinned: true,
            leading: new Container(),
            bottom: new PreferredSize(
                preferredSize: const Size.fromHeight(0.0),
                child: new Container(
                  child: new TabBar(
                    tabs: <Tab>[
                      new Tab(icon: new Icon(Icons.person, color: Theme.of(context).accentIconTheme.color)),
                      new Tab(icon: new Icon(Icons.menu, color: Theme.of(context).accentIconTheme.color)),
                      new Tab(icon: new Icon(Icons.notifications, color: Theme.of(context).accentIconTheme.color))
                    ],
                  ),
                )
            ),
          ),

          new SliverList(
              delegate: new SliverChildBuilderDelegate(
                  (context, index) => new ListTile(
                    title: new Text("item $index"),
                  )
              )
          )

        ],
      ),
    );
  }
}