import 'package:flutter/material.dart';

import '../portfolio/transaction_sheet.dart';
import '../main.dart';
import 'coin_aggregate_stats.dart';
import 'coin_exchanges_list.dart';
import '../portfolio/transactions_page.dart';

class CoinDetails extends StatefulWidget {
  CoinDetails({
    this.snapshot,
    this.enableTransactions = false,
  });

  final bool enableTransactions;
  final snapshot;

  @override
  CoinDetailsState createState() => new CoinDetailsState();
}

class CoinDetailsState extends State<CoinDetails> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _tabAmt;
  List<Widget> _tabBarChildren;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String toSym = "USD"; //TODO: setting for this

  _makeTabs() {
    if (widget.enableTransactions) {
      _tabAmt = 3;
      _tabBarChildren = [
        new Tab(text: "Stats"),
        new Tab(text: "Markets"),
        new Tab(text: "Transactions")
      ];
    } else {
      _tabAmt = 2;
      _tabBarChildren = [
        new Tab(text: "Aggregate Stats"),
        new Tab(text: "Markets")
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _makeTabs();
    _tabController = new TabController(length: _tabAmt, vsync: this);
  }

  @override
  Widget build(BuildContext context) {

    print("built coin tabs");

    return new Scaffold(
        key: _scaffoldKey,
        appBar: new PreferredSize(
          preferredSize: const Size.fromHeight(75.0),
          child: new AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            titleSpacing: 0.0,
            elevation: appBarElevation,
            title: new Text(widget.snapshot["name"], style: Theme.of(context).textTheme.title),
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
                      tabs: _tabBarChildren,
                    )
                )
            ),
            actions: <Widget>[
              new IconButton(
                  icon: new Icon(Icons.add),
                  onPressed: () {
                    _scaffoldKey.currentState.showBottomSheet((BuildContext context) {
                      return new TransactionSheet(_makeTabs, marketListData);
                    });
                }
              )
            ],
          ),
        ),
        body: new TabBarView(
          controller: _tabController,
          children: widget.enableTransactions ? [
            new AggregateStats(symbol: widget.snapshot["symbol"], id: widget.snapshot["id"].toString(), toSym: toSym),
            new MarketList(symbol: widget.snapshot["symbol"], toSym: toSym, key: new PageStorageKey("exchanges")),
            new TransactionsPage(symbol: widget.snapshot["symbol"])
          ] : [
            new AggregateStats(symbol: widget.snapshot["symbol"],
                id: widget.snapshot["id"].toString(),
                toSym: toSym),
            new MarketList(symbol: widget.snapshot["symbol"],
                toSym: toSym,
                key: new PageStorageKey("exchanges"))
          ]
        )
    );
  }
}
