import 'package:flutter/material.dart';

import '../main.dart';
import '../market_coin_item.dart';
import '../market/coin_tabs.dart';

class PortfolioBreakdownItem extends StatelessWidget {
  PortfolioBreakdownItem({this.snapshot, this.totalValue, this.color});
  final snapshot;
  final num totalValue;
  final Color color;
  final columnProps = [.2, .3, .3];

  _getImage() {
    if (assetImages.contains(snapshot["symbol"].toLowerCase())) {
      return new Image.asset(
          "assets/images/" + snapshot["symbol"].toLowerCase() + ".png",
          height: 24.0);
    } else {
      return new Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) =>
                new CoinDetails(snapshot: snapshot, enableTransactions: true)));
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
                  new Text(snapshot["symbol"],
                      style: Theme.of(context).textTheme.body2),
                ],
              ),
            ),
            new Container(
              width: MediaQuery.of(context).size.width * columnProps[2],
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Text(
                      "\$" +
                          numCommaParse((snapshot["total_quantity"] *
                                  snapshot["price_usd"])
                              .toStringAsFixed(2)),
                      style: Theme.of(context)
                          .textTheme
                          .body2
                          .apply(fontSizeFactor: 1.05)),
                ],
              ),
            ),
            new Container(
                width: MediaQuery.of(context).size.width * columnProps[1],
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Text(
                        ((snapshot["total_quantity"] * snapshot["price_usd"])
                                        .abs() /
                                    totalValue.abs() *
                                    100)
                                .toStringAsFixed(2) +
                            "%",
                        style: Theme.of(context).textTheme.body2.apply(
                            color: color,
                            fontSizeFactor: 1.3,
                            fontWeightDelta: 2)),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
