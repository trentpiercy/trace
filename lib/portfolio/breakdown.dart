import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

import '../main.dart';
import '../market_page.dart';
import 'transactions_page.dart';

class PortfolioBreakdown extends StatefulWidget {
  PortfolioBreakdown(this.totalStats, this.portfolioDisplay);
  final Map totalStats;
  final List portfolioDisplay;

  @override
  PortfolioBreakdownState createState() => new PortfolioBreakdownState();
}

class PortfolioBreakdownState extends State<PortfolioBreakdown> {
  List <CircularSegmentEntry> segments = [];

  List colors = [
    Colors.red[400],
    Colors.pink[400],
    Colors.purple[400],
    Colors.deepPurple[400],
    Colors.indigo[400],
    Colors.blue[400],
    Colors.lightBlue[400],
    Colors.cyan[400],
    Colors.teal[400]
  ];

  num value = 0;
  num cost = 0;
  num net = 0;
  num netPercent = 0;

  _getTotals() {
    value = widget.totalStats["value_usd"];

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

  _makePortions() {
    int colorInt = 0;
    widget.portfolioDisplay.forEach((coin) {
      colorInt += 1;
      segments.add(new CircularSegmentEntry(
          coin["total_quantity"] * coin["current_price_usd"],
          colors[colorInt]
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    _getTotals();
    _makePortions();
  }

  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
        onRefresh: () {},
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
                        new Text("Total Portfolio Value", style: Theme.of(context).textTheme.caption),
                        new Text("\$"+ numCommaParseNoRound(value.toStringAsFixed(2)),
                            style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 2.2)),
                      ],
                    ),
                    new Column(
                      children: <Widget>[
                        new Text("Total Net", style: Theme.of(context).textTheme.caption),
                        redGreenParse(context, net.toStringAsFixed(2), 1.4),
                        redGreenParsePercent(context, netPercent.toStringAsFixed(2), 1.2)
                      ],
                    ),
                    new Column(
                      children: <Widget>[
                        new Text("Total Cost", style: Theme.of(context).textTheme.caption),
                        new Text("\$"+cost.toStringAsFixed(2),
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
                size: new Size.square(MediaQuery.of(context).size.width*0.75),
                duration: new Duration(milliseconds: 500),
              )
            ])),

          ],
        )
    );
  }
}


class PortfolioBreakdownItem extends StatelessWidget {
  PortfolioBreakdownItem(this.snapshot);
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
    return new Container(
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
                new Text("\$"+snapshot["value"].toString()),
              ],
            ),
          ),
          new Container(
              width: MediaQuery.of(context).size.width * columnProps[1],
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Text("% of P", style: Theme.of(context).textTheme.body2),
                ],
              )
          ),
        ],
      ),
    );
  }
}