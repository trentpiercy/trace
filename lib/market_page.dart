import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'main.dart';
import 'market/coin_tabs.dart';

final assetImages = [
  '\$pac', 'abt', 'act', 'ada', 'adx', 'ae', 'agi', 'agrs', 'aion', 'amb',
  'amp', 'ant', 'apex', 'appc', 'ardr', 'ark', 'arn', 'ary', 'ast', 'atm',
  'auto', 'bat', 'bay', 'bcbc', 'bcc', 'bcd', 'bch', 'bcn', 'bco', 'bcpt',
  'bdl', 'bela', 'bix', 'blcn', 'blk', 'block', 'blz', 'bnb', 'bnt', 'bnty',
  'bos', 'bpt', 'bq', 'brd', 'btc', 'btcd', 'btcp', 'btcz', 'btg', 'btm', 'bts',
  'btx', 'burst', 'cdn', 'cdt', 'cenz', 'chat', 'chips', 'cix', 'clam', 'cloak',
  'cmt', 'cnd', 'cnx', 'cny', 'cob', 'coqui', 'cred', 'crpt', 'crw', 'cs',
  'ctr', 'cvc', 'dash', 'dat', 'data', 'dbc', 'dcn', 'dcr', 'deez', 'dent',
  'dew', 'dgb', 'dgd', 'dlt', 'dnr', 'dnt', 'doge', 'drgn', 'dta', 'dtr',
  'ebst', 'eca', 'edg', 'edo', 'edoge', 'ela', 'elf', 'elix', 'ella', 'emc',
  'emc2', 'eng', 'enj', 'eos', 'eql', 'equa', 'etc', 'eth', 'ethos', 'etn',
  'etp', 'eur', 'evx', 'exmo', 'exp', 'fair', 'fct', 'fil', 'fldc', 'flo',
  'fsn', 'ftc', 'fuel', 'fun', 'game', 'gas', 'gbp', 'gbx', 'gbyte', 'generic',
  'gno', 'gnt', 'grc', 'grs', 'gto', 'gup', 'gvt', 'gxs', 'hpb', 'hsr', 'html',
  'huc', 'hush', 'icn', 'icx', 'ignis', 'ink', 'ins', 'ion', 'iop', 'iost',
  'itc', 'jnt', 'jpy', 'kcs', 'kin', 'kmd', 'knc', 'krb', 'lbc', 'lend',
  'link', 'lkk', 'lrc', 'lsk', 'ltc', 'lun', 'maid', 'mana', 'mcap', 'mco',
  'mda', 'mds', 'med', 'miota', 'mith', 'mkr', 'mln', 'mnx', 'mnz', 'mod',
  'mona', 'mth', 'mtl', 'music', 'mzc', 'nano', 'nas', 'nav', 'ncash', 'ndz',
  'nebl', 'neo', 'neos', 'ngc', 'nio', 'nlc2', 'nlg', 'nmc', 'nuls', 'nxs',
  'nxt', 'oax', 'omg', 'omni', 'ont', 'oot', 'ost', 'ox', 'part', 'pasl', 'pay',
  'pink', 'pirl', 'pivx', 'plr', 'poa', 'poe', 'poly', 'pot', 'powr', 'ppc',
  'ppp', 'ppt', 'prl', 'pura', 'qash', 'qiwi', 'qlc', 'qrl', 'qsp', 'qtum', 'r',
  'rads', 'rcn', 'rdd', 'rdn', 'rep', 'req', 'rhoc', 'ric', 'rise', 'rlc',
  'rpx', 'rub', 'rvn', 'salt', 'san', 'sbd', 'sberbank', 'sc', 'sky', 'slr',
  'sls', 'smart', 'sngls', 'snm', 'snt', 'spank', 'sphtx', 'srn', 'start',
  'steem', 'storj', 'storm', 'strat', 'sub', 'sumo', 'sys', 'taas', 'tau',
  'tel', 'ten', 'theta', 'tix', 'tkn', 'tnb', 'tnc', 'tnt', 'trig', 'trx',
  'tzc', 'ubq', 'unity', 'usd', 'usdt', 'utk', 'ven', 'veri', 'via', 'vib',
  'vibe', 'vivo', 'vrc', 'vtc', 'wabi', 'wan', 'waves', 'wax', 'wgr', 'wings',
  'wpr', 'wtc', 'xas', 'xbc', 'xby', 'xcp', 'xdn', 'xem', 'xlm', 'xmg', 'xmr',
  'xmy', 'xp', 'xpa', 'xpm', 'xrp', 'xtz', 'xuc', 'xvc', 'xvg', 'xzc', 'yoyow',
  'zcl', 'zec', 'zel', 'zen', 'zil', 'zilla', 'zrx'
];

Future<Null> getMarketData() async {
  int numberOfCoins = 500;
  List tempMarketListData = [];

  _pullData(start, limit) async {
    var response = await http.get(
        Uri.encodeFull("https://api.coinmarketcap.com/v2/ticker/" +
            "?start=" + start.toString() +
            "&limit=" + limit.toString()),
        headers: {"Accept": "application/json"}
    );

    Map rawMarketListData = new JsonDecoder().convert(response.body)["data"];
    rawMarketListData.forEach((key, value) => tempMarketListData.add(value));

    print("pulled market data [$start - $limit]");

    if (tempMarketListData.length == numberOfCoins) {
      print("\$\$\$\$ FINISHED GETTING NEW MARKET DATA");
      marketListData = tempMarketListData;
      getApplicationDocumentsDirectory().then((Directory directory) async {
        File jsonFile = new File(directory.path + "/marketData.json");
        jsonFile.writeAsStringSync(json.encode(marketListData));
      });
    }
  }

  for (int i = 0; i <= numberOfCoins/100 - 1; i++) {
    int start = i*100 + 1;
    int limit = i*100 + 100;
    _pullData(start, limit);
  }
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
                  new Text("\$"+normalizeNum(snapshot["quotes"]["USD"]["market_cap"]),
                      style: Theme.of(context).textTheme.body2),
                  new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                  new Text("\$"+normalizeNum(snapshot["quotes"]["USD"]["volume_24h"]),
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
                  new Text("\$"+normalizeNumNoCommas(snapshot["quotes"]["USD"]["price"])),
                  new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                  new Text(
                    snapshot["quotes"]["USD"]["percent_change_24h"] >= 0 ?
                      "+"+snapshot["quotes"]["USD"]["percent_change_24h"].toStringAsFixed(2)+"%"
                      : snapshot["quotes"]["USD"]["percent_change_24h"].toStringAsFixed(2)+"%",
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
