import 'package:flutter/material.dart';

import 'main.dart';

class PortfolioPage extends StatefulWidget {
  PortfolioPage({Key key}) : super(key: key);

  @override
  PortfolioPageState createState() => new PortfolioPageState();
}

class PortfolioPageState extends State<PortfolioPage> {
  ScrollController _scrollController = new ScrollController();

  void initState() {
    super.initState();
  }

  @override
//  Widget build(BuildContext context) {
//    return new SliverList(
//        delegate: new SliverChildBuilderDelegate(
//          (context, index) => new ListTile(title: new Text("item $index"))
//        )
//    );
//  }
  
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,

      floatingActionButton: new FloatingActionButton(
        onPressed: null,
        elevation: appBarElevation,
        backgroundColor: Theme.of(context).buttonColor,
        child: new Icon(Icons.add, color: Theme.of(context).iconTheme.color),
      ),

      body: new Column(
        children: <Widget>[
//          new CustomScrollView(
//            controller: _scrollController,
//            shrinkWrap: true,
//            slivers: <Widget>[
//              new SliverAppBar(
//                floating: true,
//                pinned: false,
//
//                backgroundColor: Theme.of(context).cardColor,
//
//                title: new Text("Testing"),
//                elevation: 0.0,
////            leading: new IconButton(icon: new Icon(Icons.search), onPressed: null),
//                titleSpacing: 0.0,
//
//              ),
//
//              new SliverAppBar(
//                backgroundColor: Theme.of(context).cardColor,
//                elevation: appBarElevation,
//                pinned: true,
//                leading: new Container(),
//                bottom: new PreferredSize(
//                    preferredSize: const Size.fromHeight(0.0),
//                    child: new Container(
//                      child: new TabBar(
//                        tabs: <Tab>[
//                          new Tab(icon: new Icon(Icons.person, color: Theme.of(context).accentIconTheme.color)),
//                          new Tab(icon: new Icon(Icons.menu, color: Theme.of(context).accentIconTheme.color)),
//                          new Tab(icon: new Icon(Icons.notifications, color: Theme.of(context).accentIconTheme.color))
//                        ],
//                      ),
//                    )
//                ),
//              ),
//
//
//            ],
//          ),
//
//          new CustomScrollView(
//            controller: _scrollController,
//            shrinkWrap: true,
//            slivers: <Widget>[
//              new SliverList(
//                  delegate: new SliverChildBuilderDelegate(
//                          (context, index) => new ListTile(
//                        title: new Text("item $index"),
//                      )
//                  )
//              )
//            ],
//          )

        ],
      )

    );
  }
}