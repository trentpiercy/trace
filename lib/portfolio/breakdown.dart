import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

import '../main.dart';
import '../market_page.dart';
import '../market/coin_tabs.dart';
import 'portfolio_tabs.dart';

class PortfolioBreakdown extends StatefulWidget {
  PortfolioBreakdown({
    this.refresh,
  });

  final Function refresh;

  @override
  PortfolioBreakdownState createState() => new PortfolioBreakdownState(
    refresh: refresh,
  );
}

class PortfolioBreakdownState extends State<PortfolioBreakdown> {
  PortfolioBreakdownState({
    this.refresh,
  });

  final GlobalKey<AnimatedCircularChartState> _chartKey = new GlobalKey<AnimatedCircularChartState>();

  final columnProps = [.2,.3,.3];
  final Function refresh;

  final List colors = [
    Colors.red[400],
    Colors.purple[400],
    Colors.indigo[400],
    Colors.blue[400],
    Colors.teal[400],
    Colors.green[400],
    Colors.lime[400],
    Colors.orange[400],
  ];

  num value;
  num net;
  num netPercent;
  num cost;
  List<CircularSegmentEntry> segments;
  Map colorMap;

  @override
  void initState() {
    super.initState();
    _makeColorMap();
    _updateBreakdown();
    _sortPortfolioDisplay();
    _makeSegments();
  }

  _updateBreakdown() {
    cost = 0;
    net = 0;
    netPercent = 0;
    value = totalPortfolioStats["value_usd"];

    portfolioMap.forEach((symbol, transactions){
      transactions.forEach((transaction) {
        cost += transaction["quantity"] * transaction["price_usd"];
      });
    });

    net = value - cost;

    if (cost > 0) {
      netPercent = ((value - cost) / cost)*100;
    } else {
      netPercent = 0.0;
    }
  }

  _makeSegments() {
    segments = [];
    sortedPortfolioDisplay.forEach((coin) {
      segments.add(new CircularSegmentEntry(
          coin["total_quantity"] * coin["price_usd"],
          colorMap[coin["symbol"]],
          rankKey: coin["symbol"]
      ));
    });
    _chartKey.currentState.updateData([new CircularStackEntry(segments, rankKey: "Portfolio Breakdown")]);
  }

  _makeColorMap() {
    colorMap = {};
    int colorIndex = 0;
    portfolioDisplay.forEach((coin) {
      if (colorIndex >= colors.length) {
        colorIndex = 1;
      }
      colorMap[coin["symbol"]] = colors[colorIndex];
      colorIndex += 1;
    });
  }

  List portfolioSortType = ["holdings", true];
  List sortedPortfolioDisplay;
  _sortPortfolioDisplay() {
    sortedPortfolioDisplay = portfolioDisplay;
    if (portfolioSortType[1]) {
      if (portfolioSortType[0] == "holdings") {
        sortedPortfolioDisplay.sort((a, b) =>
            (b["price_usd"]*b["total_quantity"]).toDouble()
                .compareTo((a["price_usd"]*a["total_quantity"]).toDouble()));
      } else {
        sortedPortfolioDisplay.sort((a, b) => b[portfolioSortType[0]].compareTo(a[portfolioSortType[0]]));
      }
    } else {
      if (portfolioSortType[0] == "holdings") {
        sortedPortfolioDisplay.sort((a, b) =>
            (a["price_usd"]*a["total_quantity"]).toDouble()
                .compareTo((b["price_usd"]*b["total_quantity"]).toDouble()));
      } else {
        sortedPortfolioDisplay.sort((a, b) => a[portfolioSortType[0]].compareTo(b[portfolioSortType[0]]));
      }
    }
    _makeSegments();
    print(segments);
  }

  @override
  Widget build(BuildContext context) {
    print("built breakdown");
    return RefreshIndicator(
      onRefresh: refresh,
      child: new CustomScrollView(
        slivers: <Widget>[
          new SliverList(delegate: new SliverChildListDelegate(<Widget>[
            new Container(
              padding: const EdgeInsets.all(10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text("Portfolio Value", style: Theme.of(context).textTheme.caption),
                      new Row(
                        children: <Widget>[
                          new Text("\$" + numCommaParseNoDollar(value.toStringAsFixed(2)),
                              style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 2.2)),
                        ],
                      ),
                    ],
                  ),
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text("Total Net", style: Theme.of(context).textTheme.caption),
                      new PercentDollarChange(
                        exact: net,
                        percent: netPercent,
                      )
                    ],
                  ),
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      new Text("Total Cost", style: Theme.of(context).textTheme.caption),
                      new Text("\$" + numCommaParseNoDollar(cost.toStringAsFixed(2)),
                          style: Theme.of(context).primaryTextTheme.body2.apply(fontSizeFactor: 1.4))
                    ],
                  ),
                ],
              ),
            ),
            new AnimatedCircularChart(
              key: _chartKey,
              initialChartData: <CircularStackEntry>[
                new CircularStackEntry(segments, rankKey: "Portfolio Breakdown")
              ],
              size: new Size.square(MediaQuery.of(context).size.width*0.7),
              duration: new Duration(milliseconds: 800),
            ),
            new Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0),
              decoration: new BoxDecoration(
                  border: new Border(bottom: new BorderSide(color: Theme.of(context).dividerColor, width: 1.0))
              ),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new InkWell(
                    onTap: () {
                      if (portfolioSortType[0] == "symbol") {
                        portfolioSortType[1] = !portfolioSortType[1];
                      } else {
                        portfolioSortType = ["symbol", false];
                      }
                      setState(() {
                        _sortPortfolioDisplay();
                      });
                    },
                    child: new Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      width: MediaQuery.of(context).size.width * columnProps[0],
                      child: portfolioSortType[0] == "symbol" ?
                      new Text(portfolioSortType[1] == true ? "Currency ⬆" : "Currency ⬇",
                          style: Theme.of(context).textTheme.body2)
                          : new Text("Currency",
                        style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).hintColor),
                      ),
                    ),
                  ),
                  new InkWell(
                    onTap: () {
                      if (portfolioSortType[0] == "holdings") {
                        portfolioSortType[1] = !portfolioSortType[1];
                      } else {
                        portfolioSortType = ["holdings", true];
                      }
                      setState(() {
                        _sortPortfolioDisplay();
                      });
                    },
                    child: new Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      width: MediaQuery.of(context).size.width * columnProps[1],
                      child: portfolioSortType[0] == "holdings" ?
                      new Text(portfolioSortType[1] == true ? "Holdings ⬇" : "Holdings ⬆",
                          style: Theme.of(context).textTheme.body2)
                          : new Text("Holdings",
                          style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).hintColor)),
                    ),
                  ),
                  new Container(
                    alignment: Alignment.centerRight,
                    width: MediaQuery.of(context).size.width * columnProps[2],
                    child: new Text("Percent of Total",
                        style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).hintColor)),
                  ),
                ],
              ),
            ),
          ])),
          new SliverList(delegate: new SliverChildBuilderDelegate(
              (context, index) =>
              new PortfolioBreakdownItem(
                  snapshot: sortedPortfolioDisplay[index],
                  totalValue: totalPortfolioStats["value_usd"],
                  color: colorMap[sortedPortfolioDisplay[index]["symbol"]]
              ),
              childCount: sortedPortfolioDisplay.length
          )),
        ],
      ),
    );
  }
}


class PortfolioBreakdownItem extends StatelessWidget {
  PortfolioBreakdownItem({this.snapshot, this.totalValue, this.color});
  final snapshot;
  final num totalValue;
  final Color color;
  final columnProps = [.2,.3,.3];

  _getImage() {
    if (assetImages.contains(snapshot["symbol"].toLowerCase())) {
      return new Image.asset(
          "assets/images/" + snapshot["symbol"].toLowerCase() +
              ".png", height: 24.0);
    } else {
      return new Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: () {
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
                  new Padding(padding: const EdgeInsets.only(right: 8.0)),
                  new Text(snapshot["symbol"], style: Theme.of(context).textTheme.body2),
                ],
              ),
            ),
            new Container(
              width: MediaQuery.of(context).size.width * columnProps[2],
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Text("\$"+numCommaParseNoDollar((snapshot["total_quantity"]*snapshot["price_usd"]).toStringAsFixed(2)),
                      style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.05)),
                ],
              ),
            ),
            new Container(
                width: MediaQuery.of(context).size.width * columnProps[1],
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Text((
                        (snapshot["total_quantity"]*snapshot["price_usd"]).abs()/totalValue.abs()*100
                    ).toStringAsFixed(2)+"%", style: Theme.of(context).textTheme.body2.apply(
                        color: color, fontSizeFactor: 1.3, fontWeightDelta: 2
                    )),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}