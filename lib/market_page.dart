import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'main.dart';
import 'market/coin_tabs.dart';

final assetImages = [
  "cdt","exp","lun","ppp","tnb","abt","chips","fair","maid",
  "ppt","tnc","act","cix","fct","mana","prl","tnt","ada","clam","fil","mcap",
  "pura","trig","adx","cloak","fldc","mco","qash","trx","ae","cmt","flo","mda",
  "qiwi","tzc","agi","cnd","fsn","mds","qlc","ubq","agrs","cnx","ftc","med","qrl",
  "unity","aion","cny","fuel","miota","qsp","usd","amb","cob","fun","mkr","qtum",
  "usdt","amp","cred","game","mln","r","utk","ant","crpt","gas","mnx","rads",
  "ven","appc","cs","gbp","mod","rcn","veri","ardr","ctr","gbx","mona","rdd",
  "via","ark","cvc","gbyte","mth","rdn","vib","arn","dash","generic","mtl","rep",
  "vibe","ary","dat","gno","music","req","vivo","ast","data.pg","gnt","mzc",
  "rhoc","vrc","atm","dbc","grc","nano","ric","vtc","auto","dcn","grs","nas",
  "rise","wabi","bat","dcr","gto","nav","rlc","waves","bay","dent","gup","ncash",
  "rpx","wax","bcc","dew","gvt","ndz","rub","wgr","bcd","dgb","gxs","nebl","rvn",
  "wings","bch","dgd","hpb","neo","salt","wpr","bcn","dlt","hr","neos","san",
  "wtc","bco","dnt","html","ngc","sbd","xas","bcpt","doge","huc","nlc2",
  "sberbank","xbc","bdl","drgn","hush","nlg","sc","xby","bela","dta","icn","nmc",
  "sky","xcp","bix","dtr","icx","nuls","slr","xdn","blcn","ebst","ignis","nxs",
  "sls","xem","blk","edg","ink","nxt","smart","xlm","block","edo","ins","oax",
  "sngls","xmg","blz","edoge","ion","omg","snm","xmr","bnb","elf","iop","omni",
  "snt","xmy","bnt","elix","iost","ont","spank","xp","bnty","ella","itc","ost",
  "sphtx","xpa","bos","emc","jnt","ox","srn","xpm","bpt","emc2","jpy","part",
  "start","xrp","bq","eng","kcs","pasl","steem","xtz","brd","enj","kin","pay",
  "storj","xuc","btc","eos","kmd","pink","storm","xvc","btcd","equa","knc",
  "pirl","strat","xvg","btcp","etc","krb","pivx","sub","xzc","btcz","eth","lbc",
  "plr","sys","yoyow","btg","ethos","lend","poa","taas","zcl","btm","etn","link",
  "poe","tau","zec","bts","etp","lkk","poly","tel","zen","btx","eur","lrc","pot",
  "theta","zil","burst","evx","lsk","powr","tix","zrx","cdn","exmo","ltc","ppc","tkn"
];

Future<Null> getMarketData() async {
  List tempMarketListData = [];
  for (int i = 0; i <= 4; i++) {
    int start = i*100 + 1;
    int limit = i*100 + 100;

    var response = await http.get(
        Uri.encodeFull("https://api.coinmarketcap.com/v2/ticker/" +
            "?start=" + start.toString() +
            "&limit=" + limit.toString()),
        headers: {"Accept": "application/json"}
    );

    Map rawMarketListData = new JsonDecoder().convert(response.body)["data"];
    rawMarketListData.forEach((key, value) => tempMarketListData.add(value));
  }

  marketListData = tempMarketListData;
  getApplicationDocumentsDirectory().then((Directory directory) async {
    File jsonFile = new File(directory.path + "/marketData.json");
    jsonFile.writeAsStringSync(json.encode(marketListData));
  });

  print("\$\$\$\$ GOT NEW MARKET DATA");
}

class CoinListItem extends StatelessWidget {
  CoinListItem(this.snapshot, this.columnProps);
  final columnProps;
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

    return new InkWell(
      onTap: () {
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
                  new Text(snapshot["rank"].toString(), style: Theme.of(context).textTheme.body2.apply(
                    fontWeightDelta: 2
                  )),
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
                  new Text(numCommaParse(snapshot["quotes"]["USD"]["market_cap"].toString()),
                      style: Theme.of(context).textTheme.body2),
                  new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                  new Text(numCommaParse(snapshot["quotes"]["USD"]["volume_24h"].toString()),
                      style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).hintColor))
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
                  new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                  new Text(
                    snapshot["quotes"]["USD"]["percent_change_24h"] >= 0 ?
                      "+"+snapshot["quotes"]["USD"]["percent_change_24h"].toString()+"%"
                      : snapshot["quotes"]["USD"]["percent_change_24h"].toString()+"%",
                    style: Theme.of(context).primaryTextTheme.body1.apply(
                      color: snapshot["quotes"]["USD"]["percent_change_24h"] >= 0 ? Colors.green : Colors.red
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
