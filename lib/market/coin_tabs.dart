import 'package:flutter/material.dart';

import 'package:trace/main.dart';
import 'package:trace/market/coin_aggregate_stats.dart';
import 'package:trace/market/coin_exchanges_list.dart';
import 'package:trace/portfolio/transactions_page.dart';

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

class CoinDetailsState extends State<CoinDetails> {
  String toSym = "USD"; //TODO: setting for this

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: widget.enableTransactions ? 3 : 2,
        child: new Scaffold(
            resizeToAvoidBottomPadding: false,
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
                        child: widget.enableTransactions ?
                        new TabBar(
                          indicatorColor: Theme.of(context).accentIconTheme.color,
                          indicatorWeight: 2.0,
                          unselectedLabelColor: Theme.of(context).disabledColor,
                          labelColor: Theme.of(context).primaryIconTheme.color,
                          tabs: <Widget>[
                            new Tab(text: "Stats"),
                            new Tab(text: "Markets"),
                            new Tab(text: "Transactions")
                          ],
                        ) :
                        new TabBar(
                          indicatorColor: Theme.of(context).accentIconTheme.color,
                          indicatorWeight: 2.0,
                          unselectedLabelColor: Theme.of(context).disabledColor,
                          labelColor: Theme.of(context).primaryIconTheme.color,
                          tabs: <Widget>[
                            new Tab(text: "Aggregate Stats"),
                            new Tab(text: "Markets")
                          ],
                        ))),
              ),
            ),
            body: widget.enableTransactions ?
            new TabBarView(
              children: <Widget>[
                new AggregateStats(symbol: widget.snapshot["symbol"], id: widget.snapshot["id"].toString(), toSym: toSym),
                new MarketList(symbol: widget.snapshot["symbol"], toSym: toSym, key: new PageStorageKey("exchanges")),
                new TransactionsPage(symbol: widget.snapshot["symbol"])
              ],
            ) :
            new TabBarView(
              children: <Widget>[
                new AggregateStats(symbol: widget.snapshot["symbol"], id: widget.snapshot["id"].toString(), toSym: toSym),
                new MarketList(symbol: widget.snapshot["symbol"], toSym: toSym, key: new PageStorageKey("exchanges"))
              ],
            )
        )
    );
  }
}
