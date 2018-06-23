import 'package:flutter/material.dart';

import 'package:trace/main.dart';
import 'timeline.dart';
import 'breakdown.dart';

class PortfolioTabs extends StatefulWidget {
  PortfolioTabs(this.tab, this.totalStats, this.portfolioDisplay);
  final int tab;
  final Map totalStats;
  final List portfolioDisplay;

  @override
  PortfolioTabsState createState() => new PortfolioTabsState();
}

class PortfolioTabsState extends State<PortfolioTabs> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.animateTo(widget.tab);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new PreferredSize(
          preferredSize: const Size.fromHeight(75.0),
          child: new AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            titleSpacing: 0.0,
            elevation: appBarElevation,
            title: new Text("Portfolio", style: Theme.of(context).textTheme.title),
            bottom: new PreferredSize(
                preferredSize: const Size.fromHeight(25.0),
                child: new Container(
                    height: 30.0,
                    child: new TabBar(
                      controller: _tabController,
                      indicatorColor: Theme.of(context).accentIconTheme.color,
                      indicatorWeight: 2.0,
                      unselectedLabelColor: Theme.of(context).disabledColor,
                      labelColor: Theme.of(context).primaryIconTheme.color,
                      tabs: <Widget>[
                        new Tab(text: "Timeline"),
                        new Tab(text: "Breakdown"),
                      ],
                    ))),
          ),
        ),
        body: new TabBarView(
          controller: _tabController,
          children: <Widget>[
            new PortfolioTimeline(widget.totalStats),
            new PortfolioBreakdown(widget.totalStats, widget.portfolioDisplay)
          ],
        )
    );
  }
}