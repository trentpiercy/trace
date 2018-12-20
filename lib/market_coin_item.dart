import 'package:flutter/material.dart';

import 'main.dart';
import 'market/coin_tabs.dart';

final assetImages = ['\$pac', 'abt', 'act', 'actn', 'ada', 'adx', 'ae', 'aeon', 'agi', 'agrs', 'aion', 'amb', 'amp', 'ant', 'apex', 'appc', 'ardr', 'arg', 'ark', 'arn', 'ary', 'ast', 'atm', 'auto', 'bat', 'bay', 'bcbc', 'bcc', 'bcd', 'bch', 'bcn', 'bco', 'bcpt', 'bdl', 'bela', 'bix', 'blcn', 'blk', 'block', 'blz', 'bnb', 'bnt', 'bnty', 'bos', 'bpt', 'bq', 'brd', 'bsd', 'btc', 'btcd', 'btcp', 'btcz', 'btdx', 'btg', 'btm', 'bts', 'btx', 'burst', 'call', 'cdn', 'cdt', 'cenz', 'chat', 'chips', 'cix', 'clam', 'cloak', 'cmm', 'cmt', 'cnd', 'cnx', 'cny', 'cob', 'colx', 'coqui', 'cred', 'crpt', 'crw', 'cs', 'ctr', 'ctxc', 'cvc', 'dash', 'dat', 'data', 'dbc', 'dcn', 'dcr', 'deez', 'dent', 'dew', 'dgb', 'dgd', 'dlt', 'dnr', 'dnt', 'dock', 'doge', 'drgn', 'drop', 'dta', 'dth', 'dtr', 'ebst', 'eca', 'edg', 'edo', 'edoge', 'ela', 'elf', 'elix', 'ella', 'emc', 'emc2', 'eng', 'enj', 'eos', 'eql', 'eqli', 'equa', 'etc', 'eth', 'ethos', 'etn', 'etp', 'eur', 'evx', 'exmo', 'exp', 'fair', 'fct', 'fil', 'fjc', 'fldc', 'flo', 'fsn', 'ftc', 'fuel', 'fun', 'game', 'gas', 'gbp', 'gbx', 'gbyte', 'generic', 'gmr', 'gno', 'gnt', 'grc', 'grs', 'gsc', 'gto', 'gup', 'gusd', 'gvt', 'gxlt', 'gxs', 'gzr', 'hight', 'hodl', 'hpb', 'hsr', 'ht', 'html', 'huc', 'hush', 'icn', 'icx', 'ignis', 'ink', 'ins', 'ion', 'iop', 'iost', 'iotx', 'itc', 'jnt', 'jpy', 'kcs', 'kin', 'kmd', 'knc', 'krb', 'lbc', 'lend', 'link', 'lkk', 'loom', 'lrc', 'lsk', 'ltc', 'lun', 'maid', 'mana', 'mcap', 'mco', 'mda', 'mds', 'med', 'miota', 'mith', 'mkr', 'mln', 'mnx', 'mnz', 'moac', 'mod', 'mona', 'msr', 'mth', 'mtl', 'music', 'mzc', 'nano', 'nas', 'nav', 'ncash', 'ndz', 'nebl', 'neo', 'neos', 'neu', 'nexo', 'ngc', 'nio', 'nlc2', 'nlg', 'nmc', 'npxs', 'nuls', 'nxs', 'nxt', 'oax', 'ok', 'omg', 'omni', 'ont', 'oot', 'ost', 'ox', 'part', 'pasc', 'pasl', 'pay', 'payx', 'pink', 'pirl', 'pivx', 'plr', 'poa', 'poe', 'poly', 'pot', 'powr', 'ppc', 'ppp', 'ppt', 'prl', 'pura', 'qash', 'qiwi', 'qlc', 'qrl', 'qsp', 'qtum', 'r', 'rads', 'rap', 'rcn', 'rdd', 'rdn', 'rep', 'req', 'rhoc', 'ric', 'rise', 'rlc', 'rpx', 'rub', 'rvn', 'safe', 'salt', 'san', 'sbd', 'sberbank', 'sc', 'shift', 'sib', 'sky', 'slr', 'sls', 'smart', 'sngls', 'snm', 'snt', 'soc', 'spank', 'sphtx', 'srn', 'start', 'steem', 'storj', 'storm', 'stq', 'strat', 'sub', 'sumo', 'sys', 'taas', 'tau', 'tel', 'ten', 'tern', 'theta', 'tix', 'tkn', 'tnb', 'tnc', 'tnt', 'trig', 'trtl', 'trx', 'tusd', 'tzc', 'ubq', 'unity', 'usd', 'usdt', 'utk', 'ven', 'veri', 'vet', 'via', 'vib', 'vibe', 'vivo', 'vrc', 'vrsc', 'vtc', 'wabi', 'wan', 'waves', 'wax', 'wgr', 'wicc', 'wings', 'wpr', 'wtc', 'xas', 'xbc', 'xby', 'xcp', 'xdn', 'xem', 'xin', 'xlm', 'xmg', 'xmo', 'xmr', 'xmy', 'xp', 'xpa', 'xpm', 'xrp', 'xsg', 'xtz', 'xuc', 'xvc', 'xvg', 'xzc', 'yoyow', 'zcl', 'zec', 'zel', 'zen', 'zil', 'zilla', 'zrx'];

class CoinListItem extends StatelessWidget {
  CoinListItem(this.snapshot, this.columnProps);
  final columnProps;
  final snapshot;

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
    snapshot.forEach((k, v) {
      if (v == null) {
        snapshot[k] = "0";
      }
    });
    snapshot["quotes"]["USD"].forEach((k, v) {
      if (v == null) {
        snapshot["quotes"]["USD"][k] = 0;
      }
    });

    return new InkWell(
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) =>
                  new CoinDetails(snapshot: snapshot)));
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
                    new Text(snapshot["rank"].toString(),
                        style: Theme.of(context)
                            .textTheme
                            .body2
                            .apply(fontWeightDelta: 2)),
                    new Padding(padding: const EdgeInsets.only(right: 7.0)),
                    _getImage(),
                    new Padding(padding: const EdgeInsets.only(right: 7.0)),
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
                          "\$" +
                              normalizeNum(
                                  snapshot["quotes"]["USD"]["market_cap"]),
                          style: Theme.of(context).textTheme.body2),
                      new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                      new Text(
                          "\$" +
                              normalizeNum(
                                  snapshot["quotes"]["USD"]["volume_24h"]),
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
                    new Text("\$" +
                        normalizeNumNoCommas(
                            snapshot["quotes"]["USD"]["price"])),
                    new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                    new Text(
                        (snapshot["quotes"]["USD"]["percent_change_24h"] ?? 0) >= 0
                            ? "+" + (snapshot["quotes"]["USD"]["percent_change_24h"] ?? 0)
                                    .toStringAsFixed(2) + "%"
                            : (snapshot["quotes"]["USD"]["percent_change_24h"] ?? 0)
                                    .toStringAsFixed(2) + "%",
                        style: Theme.of(context).primaryTextTheme.body1.apply(
                            color: (snapshot["quotes"]["USD"]["percent_change_24h"] ?? 0) >= 0
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
