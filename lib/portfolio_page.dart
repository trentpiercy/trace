import 'package:flutter/material.dart';
import 'dart:async';

import 'main.dart';
import 'package:trace/market/coin_tabs.dart';
import 'package:trace/market_page.dart';
import 'package:trace/market/coin_aggregate_stats.dart';

class PortfolioPage extends StatefulWidget {
  PortfolioPage(
      this.portfolioMap,
      this.portfolioDisplay,
      this.totalPortfolioStats,
      this.makePortfolioDisplayList,
      {Key key}
  ) : super(key: key);

  final Map portfolioMap;
  final List portfolioDisplay;
  final Map totalPortfolioStats;

  final Function makePortfolioDisplayList;

  @override
  PortfolioPageState createState() => new PortfolioPageState();
}

class PortfolioPageState extends State<PortfolioPage> {
  final columnProps = [.2,.3,.3];

  Future<Null> _refresh() async {
    widget.makePortfolioDisplayList();
  }

  void initState() {
    super.initState();
    print("INIT PORTFOLIO");
  }


  @override
  Widget build(BuildContext context) {
    print("[P] built portfolio page");

    return new RefreshIndicator(
      onRefresh: _refresh,
      child: widget.totalPortfolioStats != null ? new CustomScrollView(
        slivers: <Widget>[
          new SliverList(
              delegate: new SliverChildListDelegate(<Widget>[
                new Container(
                  padding: const EdgeInsets.all(10.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text("Total Portfolio Value", style: Theme.of(context).textTheme.caption),
                          new Text("\$"+ numCommaParseNoRound(widget.totalPortfolioStats["value_usd"].toStringAsFixed(2)),
                              style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 2.2)
                          ),
                        ],
                      ),
                      new Column(
                        children: <Widget>[
                          new Text("7D Change", style: Theme.of(context).textTheme.caption),
                          new Text(
                              widget.totalPortfolioStats["percent_change_7d"] >= 0 ? "+"+widget.totalPortfolioStats["percent_change_7d"].toStringAsFixed(2)+"%" : widget.totalPortfolioStats["percent_change_7d"].toStringAsFixed(2)+"%",
                              style: Theme.of(context).primaryTextTheme.body2.apply(
                                color: widget.totalPortfolioStats["percent_change_7d"] >= 0 ? Colors.green : Colors.red,
                                fontSizeFactor: 1.8,
                              )
                          )
                        ],
                      ),
                      new Column(
                        children: <Widget>[
                          new Text("24h Change", style: Theme.of(context).textTheme.caption),
                          new Text(
                              widget.totalPortfolioStats["percent_change_24h"] >= 0 ? "+"+widget.totalPortfolioStats["percent_change_24h"].toStringAsFixed(2)+"%" : widget.totalPortfolioStats["percent_change_24h"].toStringAsFixed(2)+"%",
                              style: Theme.of(context).primaryTextTheme.body2.apply(
                                color: widget.totalPortfolioStats["percent_change_24h"] >= 0 ? Colors.green : Colors.red,
                                fontSizeFactor: 1.8
                              )
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                new Container(
                  margin: const EdgeInsets.only(left: 6.0, right: 6.0),
                  decoration: new BoxDecoration(
                      border: new Border(bottom: new BorderSide(color: Theme.of(context).dividerColor, width: 1.0))
                  ),
                  padding: const EdgeInsets.only(bottom: 8.0, left: 2.0, right: 2.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Container(
                        width: MediaQuery.of(context).size.width * columnProps[0],
                        child: new Text("Currency", style: Theme.of(context).textTheme.body2),
                      ),
                      new Container(
                        alignment: Alignment.centerRight,
                        width: MediaQuery.of(context).size.width * columnProps[1],
                        child: new Text("Holdings", style: Theme.of(context).textTheme.body2),
                      ),
                      new Container(
                        alignment: Alignment.centerRight,
                        width: MediaQuery.of(context).size.width * columnProps[2],
                        child: new Text("Price/24h", style: Theme.of(context).textTheme.body2),
                      ),
                    ],
                  ),
                ),

              ])
          ),

          new SliverList(delegate: new SliverChildBuilderDelegate(
                  (context, index) => new PortfolioListItem(widget.portfolioDisplay[index]),
              childCount: widget.portfolioDisplay != null ? widget.portfolioDisplay.length : 0
          ))

        ],
      ) : new Container(
        child: new Center(child: new CircularProgressIndicator()),
      )
    );
  }
}

class PortfolioListItem extends StatelessWidget {
  PortfolioListItem(this.snapshot);
  final snapshot;

  final columnProps = [.2,.3,.3];

  _getImage() {
    if (assetImages.contains(snapshot["symbol"].toLowerCase())) {
      return new Image.asset(
          "assets/images/" + snapshot["symbol"].toLowerCase() +
              ".png", height: 28.0);

    } else {
      return new Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () {
          resetCoinStats();
          resetExchangeData();
          Navigator.of(context).push(
              new MaterialPageRoute(
                  builder: (BuildContext context) => new CoinDetails(snapshot: snapshot, enableTransactions: true)
              )
          );
        },
        child: new Container(
          decoration: new BoxDecoration(),
          padding: const EdgeInsets.all(8.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Container(
                width: MediaQuery.of(context).size.width * columnProps[0],
                child: new Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _getImage(),
                    new Padding(padding: const EdgeInsets.only(right: 10.0)),
                    new Text(snapshot["symbol"], style: Theme.of(context).textTheme.body2),
                  ],
                ),
              ),
              new Container(
                  width: MediaQuery.of(context).size.width * columnProps[1],
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      new Text("\$"+numCommaParseNoRound((snapshot["total_quantity"]*snapshot["price_usd"]).toStringAsFixed(2)), style: Theme.of(context).textTheme.body2),
                      new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                      new Text(num.parse(snapshot["total_quantity"].toStringAsPrecision(9)).toString(), style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).hintColor))
                    ],
                  )
              ),
              new Container(
                width: MediaQuery.of(context).size.width * columnProps[2],
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Text("\$"+snapshot["price_usd"].toString()),
                    new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                    new Text(
                        snapshot["percent_change_24h"] >= 0 ? "+"+snapshot["percent_change_24h"].toString()+"%" : snapshot["percent_change_24h"].toString()+"%",
                        style: Theme.of(context).primaryTextTheme.body1.apply(
                            color: snapshot["percent_change_24h"] >= 0 ? Colors.green : Colors.red
                        )
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}
