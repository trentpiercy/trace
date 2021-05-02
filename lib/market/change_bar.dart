import 'package:flutter/material.dart';
import '../main.dart';

final Map ohlcvWidthOptions = {
  "1h": [
    ["1m", 60, 1, "minute"],
    ["2m", 30, 2, "minute"],
    ["3m", 20, 3, "minute"]
  ],
  "6h": [
    ["5m", 72, 5, "minute"],
    ["10m", 36, 10, "minute"],
    ["15m", 24, 15, "minute"]
  ],
  "12h": [
    ["10m", 72, 10, "minute"],
    ["15m", 48, 15, "minute"],
    ["30m", 24, 30, "minute"]
  ],
  "24h": [
    ["15m", 96, 15, "minute"],
    ["30m", 48, 30, "minute"],
    ["1h", 24, 1, "hour"]
  ],
  "3D": [
    ["1h", 72, 1, "hour"],
    ["2h", 36, 2, "hour"],
    ["4h", 18, 4, "hour"]
  ],
  "7D": [
    ["2h", 86, 2, "hour"],
    ["4h", 42, 4, "hour"],
    ["6h", 28, 6, "hour"]
  ],
  "1M": [
    ["12h", 60, 12, "hour"],
    ["1D", 30, 1, "day"]
  ],
  "3M": [
    ["1D", 90, 1, "day"],
    ["2D", 45, 2, "day"],
    ["3D", 30, 3, "day"]
  ],
  "6M": [
    ["2D", 90, 2, "day"],
    ["3D", 60, 3, "day"],
    ["7D", 26, 7, "day"]
  ],
  "1Y": [
    ["7D", 52, 7, "day"],
    ["14D", 26, 14, "day"]
  ],
};

class QuickPercentChangeBar extends StatelessWidget {
  QuickPercentChangeBar({this.snapshot});
  final Map snapshot;

  @override
  Widget build(BuildContext context) {
    snapshot.forEach((K, V) {
      if (V == null) {
        snapshot[K] = 0;
      }
    });
    return new Container(
      padding:
          const EdgeInsets.only(left: 6.0, right: 6.0, bottom: 3.0, top: 3.0),
      decoration: new BoxDecoration(
          border: new Border(
            top: new BorderSide(color: Theme.of(context).bottomAppBarColor),
          ),
          color: Theme.of(context).primaryColor),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text("1h",
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .apply(color: Theme.of(context).hintColor)),
              new Padding(padding: const EdgeInsets.only(right: 3.0)),
              new Text(
                  snapshot["CHANGEPCTHOUR"] >= 0
                      ? "+" + snapshot["CHANGEPCTHOUR"].toStringAsFixed(2) + "%"
                      : snapshot["CHANGEPCTHOUR"].toStringAsFixed(2) + "%",
                  style: Theme.of(context).primaryTextTheme.body2.apply(
                      color: snapshot["CHANGEPCTHOUR"] >= 0
                          ? Colors.green
                          : Colors.red))
            ],
          ),
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text("24h",
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .apply(color: Theme.of(context).hintColor)),
              new Padding(padding: const EdgeInsets.only(right: 3.0)),
              new Text(
                  snapshot["CHANGEPCT24HOUR"] >= 0
                      ? "+" + snapshot["CHANGEPCT24HOUR"].toStringAsFixed(2) + "%"
                      : snapshot["CHANGEPCT24HOUR"].toStringAsFixed(2) + "%",
                  style: Theme.of(context).primaryTextTheme.body2.apply(
                      color: snapshot["CHANGEPCT24HOUR"] >= 0
                          ? Colors.green
                          : Colors.red))
            ],
          ),
          // new Row(
          //   mainAxisSize: MainAxisSize.min,
          //   children: <Widget>[
          //     new Text("7D",
          //         style: Theme.of(context)
          //             .textTheme
          //             .body1
          //             .apply(color: Theme.of(context).hintColor)),
          //     new Padding(padding: const EdgeInsets.only(right: 3.0)),
          //     new Text(
          //         snapshot["percent_change_7d"] >= 0
          //             ? "+" + snapshot["percent_change_7d"].toString() + "%"
          //             : snapshot["percent_change_7d"].toString() + "%",
          //         style: Theme.of(context).primaryTextTheme.body2.apply(
          //             color: snapshot["percent_change_7d"] >= 0
          //                 ? Colors.green
          //                 : Colors.red)),
          //   ],
          // )
        ],
      ),
    );
  }
}
