import 'package:flutter/material.dart';

import 'main.dart';
import 'portfolio_page.dart';
import 'market_page.dart';

class Tabs extends StatefulWidget {
  Tabs(
      this.toggleTheme,
      this.handleUpdate,
      this.darkEnabled,
      this.themeMode,
      );

  final toggleTheme;
  final handleUpdate;

  final darkEnabled;
  final themeMode;


  @override
  TabsState createState() => new TabsState();
}

class TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 3, vsync: this);
    _tabController.addListener(() { //TODO: laggy - try different approach - possibly change top appBar on let go of swipe
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  PageStorageKey _marketKey = new PageStorageKey("market");
  PageStorageKey _portfolioKey = new PageStorageKey("portfolio");
  PageStorageKey _portfolioKey2 = new PageStorageKey("portfolio2");

  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {

    print("built tabs @@@@@@@");

    return new Scaffold(
        drawer: new Drawer(
            child: new Scaffold(
                bottomNavigationBar: new Container(
                    decoration: new BoxDecoration(
                        border: new Border(
                            top: new BorderSide(color: Theme.of(context).dividerColor),
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
//                    new ListTile(
//                      leading: new Icon(Icons.settings),
//                      title: new Text("Settings"),
//                    ),
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

        body: new NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              new SliverAppBar(
                title: [
                  new Text("Portfolio"),
                  new GestureDetector(
                    onTap: () => print("search - appbar"), //Navigator.of(context).pushNamed("/settings"),
                    child: new Text("Aggregate Markets"),
                  ),
                  new Text("Alerts")
                ][_tabController.index],

                actions: <Widget>[
                  [
                    new Container(),
                    new IconButton( // TODO: Searching
                        icon: new Icon(Icons.search, color: Theme.of(context).primaryIconTheme.color),
                        onPressed: () => print("search - icon") //Navigator.of(context).pushNamed("/settings")
                    ),
                    new Container()
                  ][_tabController.index],
                ],

                pinned: true,
                floating: true,
                titleSpacing: 3.0,
                elevation: appBarElevation,
                forceElevated: innerBoxIsScrolled,

                bottom: new PreferredSize(
                    preferredSize: const Size.fromHeight(45.0),
                    child: new Container(
                      height: 45.0,
                      child: new TabBar(
                        controller: _tabController,
                        indicatorColor: Theme.of(context).accentIconTheme.color,
                        unselectedLabelColor: Theme.of(context).disabledColor,
                        labelColor: Theme.of(context).accentIconTheme.color,
                        tabs: <Tab>[
                          new Tab(icon: new Icon(Icons.person)),
                          new Tab(icon: new Icon(Icons.menu)),
                          new Tab(icon: new Icon(Icons.notifications))
                        ],
                      ),
                    )
                ),
              )

            ];
          },

          body: new TabBarView(
            controller: _tabController,
            children: <Widget>[
              new PortfolioPage(key: _portfolioKey),
              new MarketPage(key: _marketKey),
              new PortfolioPage(key: _portfolioKey2,)
            ],
          ),
        )

    );
  }
}