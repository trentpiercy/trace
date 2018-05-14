import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trace/market/coin_tabs.dart';
import 'package:trace/market/coin_aggregate_stats.dart';

final columnProps = [.3,.3,.25];

final assetImages = ["cdt","exp","lun","ppp","tnb","abt","chips","fair","maid","ppt","tnc","act","cix","fct","mana","prl","tnt","ada","clam","fil","mcap","pura","trig","adx","cloak","fldc","mco","qash","trx","ae","cmt","flo","mda","qiwi","tzc","agi","cnd","fsn","mds","qlc","ubq","agrs","cnx","ftc","med","qrl","unity","aion","cny","fuel","miota","qsp","usd","amb","cob","fun","mkr","qtum","usdt","amp","cred","game","mln","r","utk","ant","crpt","gas","mnx","rads","ven","appc","cs","gbp","mod","rcn","veri","ardr","ctr","gbx","mona","rdd","via","ark","cvc","gbyte","mth","rdn","vib","arn","dash","generic","mtl","rep","vibe","ary","dat","gno","music","req","vivo","ast","data.pg","gnt","mzc","rhoc","vrc","atm","dbc","grc","nano","ric","vtc","auto","dcn","grs","nas","rise","wabi","bat","dcr","gto","nav","rlc","waves","bay","dent","gup","ncash","rpx","wax","bcc","dew","gvt","ndz","rub","wgr","bcd","dgb","gxs","nebl","rvn","wings","bch","dgd","hpb","neo","salt","wpr","bcn","dlt","hr","neos","san","wtc","bco","dnt","html","ngc","sbd","xas","bcpt","doge","huc","nlc2","sberbank","xbc","bdl","drgn","hush","nlg","sc","xby","bela","dta","icn","nmc","sky","xcp","bix","dtr","icx","nuls","slr","xdn","blcn","ebst","ignis","nxs","sls","xem","blk","edg","ink","nxt","smart","xlm","block","edo","ins","oax","sngls","xmg","blz","edoge","ion","omg","snm","xmr","bnb","elf","iop","omni","snt","xmy","bnt","elix","iost","ont","spank","xp","bnty","ella","itc","ost","sphtx","xpa","bos","emc","jnt","ox","srn","xpm","bpt","emc2","jpy","part","start","xrp","bq","eng","kcs","pasl","steem","xtz","brd","enj","kin","pay","storj","xuc","btc","eos","kmd","pink","storm","xvc","btcd","equa","knc","pirl","strat","xvg","btcp","etc","krb","pivx","sub","xzc","btcz","eth","lbc","plr","sys","yoyow","btg","ethos","lend","poa","taas","zcl","btm","etn","link","poe","tau","zec","bts","etp","lkk","poly","tel","zen","btx","eur","lrc","pot","theta","zil","burst","evx","lsk","powr","tix","zrx","cdn","exmo","ltc","ppc","tkn"];

numCommaParse(numString) {
  return "\$"+ num.parse(numString).round().toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
}
numCommaParseNoDollar(numString) {
  return num.parse(numString).round().toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
}

class MarketPage extends StatefulWidget {
  MarketPage(
      this.filter,
      this.isSearching,
      {Key key}) : super(key: key);

  final filter;
  final isSearching;

  @override
  MarketPageState createState() => new MarketPageState();
}


List marketListData;
Map globalData;

class MarketPageState extends State<MarketPage> {
  List filteredMarketData;

  int limit = 500;

  Future<Null> getGlobalData() async {
    var response = await http.get(
        Uri.encodeFull("https://api.coinmarketcap.com/v2/global/"),
        headers: {"Accept": "application/json"}
    );

    setState(() {
      globalData = new JsonDecoder().convert(response.body)["data"]["quotes"]["USD"];
    });
  }

  Future<Null> getMarketData() async {
    var response = await http.get(
        Uri.encodeFull("https://api.coinmarketcap.com/v2/ticker/?limit="+limit.toString()),
        headers: {"Accept": "application/json"}
    );

    Map rawMarketListData = new JsonDecoder().convert(response.body)["data"];
//    List marketListData = new JsonDecoder().convert(response.body);

    marketListData = [];
    rawMarketListData.forEach((key, value) => marketListData.add(value));

    filteredMarketData = marketListData;

    setState(() {});
  }

  Future<Null> refreshData() async {
    getGlobalData();
    getMarketData();
  }

  filterMarketData() {
    if (widget.filter == "" || widget.filter == null) {
      filteredMarketData = marketListData;
    } else {
      filteredMarketData = [];
      marketListData.forEach((item) {
        if (item["symbol"].toLowerCase().contains(widget.filter.toLowerCase()) ||
            item["name"].toLowerCase().contains(widget.filter.toLowerCase())) {
          filteredMarketData.add(item);
        }
      });
    }
  }


  @override
  void initState() {
    print("INIT MARKETS");
    super.initState();

    if (marketListData == null) {
      getMarketData();
    }
    if (globalData == null) {
      getGlobalData();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    print("built markets & filtered***");
    filterMarketData();
    
    return filteredMarketData != null && globalData != null ? new RefreshIndicator(
        onRefresh: () => refreshData(),
        child: new CustomScrollView(
          slivers: <Widget>[
            widget.isSearching != true ? new SliverList(
                delegate: new SliverChildListDelegate(<Widget>[
                  new Container(
                      padding: const EdgeInsets.all(10.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text("Total Market Cap", style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).hintColor)),
                              new Padding(padding: const EdgeInsets.symmetric(vertical: 1.0)),
                              new Text("Total 24h Volume", style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).hintColor)),
                            ],
                          ),
                          new Padding(padding: const EdgeInsets.symmetric(horizontal: 1.0)),
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              new Text(numCommaParse(globalData["total_market_cap"].toString()),
                                  style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.2, fontWeightDelta: 2)
                              ),
                              new Text(numCommaParse(globalData["total_volume_24h"].toString()),
                                  style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.2, fontWeightDelta: 2)
                              ),
                            ],
                          )
                        ],
                      )
                  ),
                  new Container(
                    margin: const EdgeInsets.only(left: 6.0, right: 6.0, top: 8.0),
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
                          child: new Text("Market Cap/24h", style: Theme.of(context).textTheme.body2),
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
            ) : new SliverPadding(padding: const EdgeInsets.all(0.0)),

            filteredMarketData.isEmpty ? new SliverList(
                delegate: new SliverChildListDelegate(
                  <Widget>[
                    new Container(
                      padding: const EdgeInsets.all(30.0),
                      alignment: Alignment.topCenter,
                      child: new Text("No results found", style: Theme.of(context).textTheme.caption),
                    )
                  ]
                )
            ) :
            new SliverList(delegate: new SliverChildBuilderDelegate(
              (BuildContext context, int index) {return new CoinListItem(snapshot: filteredMarketData[index]);},
              childCount: filteredMarketData == null ? 0 : filteredMarketData.length
            ))

          ],
        )

    ) : new Container(
      child: new Center(child: new CircularProgressIndicator()),
    );
  }
}

class CoinListItem extends StatelessWidget {
  CoinListItem({this.snapshot});
  final snapshot;

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
    snapshot.forEach((k, v) {
      if (v == null) {
        snapshot[k] = "0";
      }
    });

    return new GestureDetector(
      onTap: () {
        resetCoinStats();
        resetExchangeData();
        Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (BuildContext context) => new CoinDetails(snapshot: snapshot)
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
                  new Text(snapshot["rank"].toString(), style: Theme.of(context).textTheme.body2),
                  new Padding(padding: const EdgeInsets.only(right: 7.0)),
                  _getImage(),
                  new Padding(padding: const EdgeInsets.only(right: 7.0)),
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
                  new Text(numCommaParse(snapshot["quotes"]["USD"]["market_cap"].toString()), style: Theme.of(context).textTheme.body2),
//                  new Text(numCommaParse(snapshot["market_cap_usd"].toString()), style: Theme.of(context).textTheme.body2),
                  new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                  new Text(numCommaParse(snapshot["quotes"]["USD"]["volume_24h"].toString()), style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).hintColor))
//                  new Text(numCommaParse(snapshot["24h_volume_usd"].toString()), style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).hintColor))
                ],
              )
            ),
            new Container(
              width: MediaQuery.of(context).size.width * columnProps[2],
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Text("\$"+snapshot["quotes"]["USD"]["price"].toString()),
//                  new Text("\$"+snapshot["price_usd"].toString()),
                  new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                  new Text(
                    snapshot["quotes"]["USD"]["percent_change_24h"] >= 0 ? "+"+snapshot["quotes"]["USD"]["percent_change_24h"].toString()+"%" : snapshot["quotes"]["USD"]["percent_change_24h"].toString()+"%",
//                    snapshot["percent_change_24h"].toDouble() >= 0 ? "+"+snapshot["percent_change_24h"].toString()+"%" : snapshot["percent_change_24h"].toString()+"%",
                    style: Theme.of(context).primaryTextTheme.body1.apply(
                      color: snapshot["quotes"]["USD"]["percent_change_24h"] >= 0 ? Colors.green : Colors.red
//                        color: snapshot["percent_change_24h"].toDouble() >= 0 ? Colors.green : Colors.red
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

