import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

import '../main.dart';
import '../market_page.dart';
import '../market/coin_aggregate_stats.dart';
import '../market/coin_exchanges_list.dart';
import '../market/coin_tabs.dart';
import 'portfolio_tabs.dart';

class PortfolioBreakdown extends StatelessWidget {
  PortfolioBreakdown({
    this.totalStats,
    this.portfolioDisplay,
    this.value,
    this.net,
    this.netPercent,
    this.cost,
    this.segments,
    this.colors,
  });

  final columnProps = [.2,.3,.3];

  final Map totalStats;
  final List portfolioDisplay;
  final num value;
  final num net;
  final num netPercent;
  final num cost;
  final List<CircularSegmentEntry> segments;

  final List colors;

  @override
  Widget build(BuildContext context) {
    print("built breakdown");
    return new CustomScrollView(
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
                        new Padding(padding: const EdgeInsets.symmetric(horizontal: 3.0)),
                        new PercentDollarChange(
                          exact: net,
                          percent: netPercent,
                        )
                      ],
                    ),
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
            initialChartData: <CircularStackEntry>[
              new CircularStackEntry(segments, rankKey: "Portfolio Breakdown")
            ],
            size: new Size.square(MediaQuery.of(context).size.width*0.7),
            duration: new Duration(milliseconds: 400),
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
                  child: new Text("Percent of Total", style: Theme.of(context).textTheme.body2),
                ),
              ],
            ),
          ),
        ])),
        new SliverList(delegate: new SliverChildBuilderDelegate(
                (context, index) {
                  int colorIndex = index;
                  if (colorIndex > (colors.length-1)) {
                    colorIndex = index-((index/(colors.length-1)).floor()*(colors.length-1));
                  }
                  return new PortfolioBreakdownItem(
                      portfolioDisplay[index],
                      totalStats["value_usd"],
                      colors[colorIndex]
                  );
                },
            childCount: portfolioDisplay.length
        )),
      ],
    );
  }
}


class PortfolioBreakdownItem extends StatelessWidget {
  PortfolioBreakdownItem(this.snapshot, this.totalValue, this.symbolColor);
  final snapshot;
  final num totalValue;
  final Color symbolColor;
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
                        (snapshot["total_quantity"]*snapshot["price_usd"])/totalValue*100
                    ).toStringAsFixed(2)+"%", style: Theme.of(context).textTheme.body2.apply(
                        color: symbolColor, fontSizeFactor: 1.3, fontWeightDelta: 2
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