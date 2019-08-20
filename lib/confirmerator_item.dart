import 'package:flutter/material.dart';

import 'main.dart';
import 'market/coin_tabs.dart';
import 'market_coin_item.dart';

class ConfirmeratorListItem extends StatelessWidget {
  ConfirmeratorListItem(this.snapshot, this.columnProps);
  final snapshot;
  final columnProps;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _getImage() {
    if (assetImages.contains(snapshot["symbol"].toLowerCase())) {
      return new Image.asset(
          "assets/images/" + snapshot["symbol"].toLowerCase() + ".png",
          height: 28.0);
    } else {
      return new Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new InkWell(
        onTap: () {
      _scaffoldKey.currentState
          .showBottomSheet((BuildContext context) {
        return;
      });
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
                  width: MediaQuery.of(context).size.width * columnProps[1],
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      new Text(
                          snapshot["nickname"],
                          style: Theme.of(context).textTheme.body2),
                      new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                      new Text(
                          snapshot["walletAddr"].toString().substring(0, 5) +
                              "....." +
                              snapshot["walletAddr"].toString().substring(snapshot["walletAddr"].toString().length - 5, snapshot["walletAddr"].toString().length),
                          style: Theme.of(context)
                              .textTheme
                              .body2
                              .apply(color: Theme.of(context).hintColor))
                    ],
                  )),
              new Container(
                width: MediaQuery.of(context).size.width * columnProps[2],
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Text(
                        "PlaceHolder, deposits"),
                    new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                    new Text(
                        (snapshot["track"] )
                            ? "Tracking"
                            : "Ignoring",
                        style: Theme.of(context).primaryTextTheme.body1.apply(
                            color: (snapshot["track"])
                                ? Colors.green
                                : Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
