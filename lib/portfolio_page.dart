import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'market_page.dart';

class PortfolioPage extends StatefulWidget {
  PortfolioPage(this.portfolioMap, this.totalsList, {Key key}) : super(key: key);

  final Map portfolioMap;
  final List totalsList;

  @override
  PortfolioPageState createState() => new PortfolioPageState();
}

class PortfolioPageState extends State<PortfolioPage> {
  final columnProps = [.2,.3,.3];

  int limit = 500;
  Future<Null> getMarketData() async {
    var response = await http.get(
        Uri.encodeFull("https://api.coinmarketcap.com/v2/ticker/?limit="+limit.toString()),
        headers: {"Accept": "application/json"}
    );

    Map rawMarketListData = new JsonDecoder().convert(response.body)["data"];

    marketListData = rawMarketListData.values.toList();
  }

  Future<Null> refreshMarketData() async {
    await getMarketData();
    setState(() {});
  }





  void initState() {
    super.initState();
    print("INIT PORTFOLIO");
    if (marketListData == null) {refreshMarketData();}
  }


  @override
  Widget build(BuildContext context) {

    print("[P] built portfolio page");

    return new CustomScrollView(
        slivers: <Widget>[
          new SliverList(
              delegate: new SliverChildListDelegate(<Widget>[
                new Container(
                  padding: const EdgeInsets.all(10.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text("Total Portfolio Value", style: Theme.of(context).textTheme.caption),
                          new Text("\$"+"VALUE", style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 2.2)),
                        ],
                      ),
                      new Row(
                        children: <Widget>[
                          new Text("24h", style: Theme.of(context).textTheme.caption),
                          new Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0)),
                          new Text("+99%", style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.2)),
                        ],
                      )
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
                        child: new Text("Holdings/24h", style: Theme.of(context).textTheme.body2),
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
            (context, index) => new ListTile(
              title: new Text("placeholder $index"),
            ))
          )

        ],
    );
  }
}