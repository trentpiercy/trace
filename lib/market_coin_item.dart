import 'package:flutter/material.dart';

import 'main.dart';
import 'market/coin_tabs.dart';

final assetImages = ['\$pac', 'booty', 'data', 'exp', 'iop', 'ncash', 'pura', 'storj', 'wgr', '2give', 'bos', 'dbc', 'fair', 'iost', 'ndz', 'qash', 'storm', 'wicc', 'abt', 'bpt', 'dcn', 'fct', 'iotx', 'nebl', 'qiwi', 'stq', 'wings', 'act', 'bq', 'dcr', 'fil', 'itc', 'neo', 'qlc', 'strat', 'wpr', 'actn', 'brd', 'deez', 'fjc', 'jnt', 'neos', 'qrl', 'sub', 'wtc', 'ada', 'bsd', 'dent', 'fldc', 'jpy', 'neu', 'qsp', 'sumo', 'x', 'adx', 'btc', 'dew', 'flo', 'kcs', 'nexo', 'qtum', 'sys', 'xas', 'ae', 'btcd', 'dgb', 'fsn', 'kin', 'ngc', 'r', 'taas', 'xbc', 'aeon', 'btch', 'dgd', 'ftc', 'kmd', 'nio', 'rads', 'tau', 'xby', 'agi', 'btcp', 'dlt', 'fuel', 'knc', 'nlc2', 'rap', 'tel', 'xcp', 'agrs', 'btcz', 'dnr', 'fun', 'krb', 'nlg', 'rcn', 'ten', 'xdn', 'aion', 'btdx', 'dnt', 'game', 'lbc', 'nmc', 'rdd', 'tern', 'xem', 'amb', 'btg', 'dock', 'gas', 'lend', 'npxs', 'rdn', 'tghc', 'xin', 'amp', 'btm', 'doge', 'gbp', 'link', 'nuls', 'rep', 'theta', 'xlm', 'ant', 'bts', 'drgn', 'gbx', 'lkk', 'nxs', 'req', 'tix', 'xmcc', 'apex', 'btx', 'drop', 'gbyte', 'loom', 'nxt', 'rhoc', 'tkn', 'xmg', 'appc', 'burst', 'dta', 'generic', 'lpt', 'oax', 'ric', 'tks', 'xmo', 'ardr', 'call', 'dth', 'glxt', 'lrc', 'ok', 'rise', 'tnb', 'xmr', 'arg', 'cc', 'dtr', 'gmr', 'lsk', 'omg', 'rlc', 'tnc', 'xmy', 'ark', 'cdn', 'ebst', 'gno', 'ltc', 'omni', 'rpx', 'tnt', 'xp', 'arn', 'cdt', 'eca', 'gnt', 'lun', 'ong', 'rub', 'tpay', 'xpa', 'ary', 'cenz', 'edg', 'grc', 'maid', 'ont', 'rvn', 'trig', 'xpm', 'ast', 'chain', 'edo', 'grs', 'mana', 'oot', 'ryo', 'trtl', 'xrp', 'atm', 'chat', 'edoge', 'gsc', 'mcap', 'ost', 'safe', 'trx', 'xsg', 'auto', 'chips', 'ela', 'gto', 'mco', 'ox', 'salt', 'tusd', 'xtz', 'aywa', 'cix', 'elf', 'gup', 'mda', 'part', 'san', 'tzc', 'xuc', 'bat', 'clam', 'elix', 'gusd', 'mds', 'pasc', 'sbd', 'ubq', 'xvc', 'bay', 'cloak', 'ella', 'gvt', 'med', 'pasl', 'sberbank', 'unity', 'xvg', 'bcbc', 'cmm', 'emc', 'gxlt', 'miota', 'pay', 'sc', 'usd', 'xzc', 'bcc', 'cmt', 'emc2', 'gxs', 'mith', 'payx', 'shift', 'usdt', 'yoyow', 'bcd', 'cnd', 'eng', 'gzr', 'mkr', 'pgt', 'sib', 'utk', 'zcl', 'bch', 'cnx', 'enj', 'hight', 'mln', 'pink', 'sky', 'ven', 'zec', 'bcn', 'cny', 'entrp', 'hodl', 'mnx', 'pirl', 'slr', 'veri', 'zel', 'bco', 'cob', 'eos', 'hpb', 'mnz', 'pivx', 'sls', 'vet', 'zen', 'bcpt', 'colx', 'eql', 'hsr', 'moac', 'plr', 'smart', 'via', 'zest', 'bdl', 'coqui', 'eqli', 'ht', 'mod', 'poa', 'sngls', 'vib', 'zil', 'bela', 'cred', 'equa', 'html', 'mona', 'poe', 'snm', 'vibe', 'zilla', 'bix', 'crpt', 'etc', 'huc', 'msr', 'polis', 'snt', 'vivo', 'zrx', 'blcn', 'crw', 'eth', 'hush', 'mth', 'poly', 'soc', 'vrc', 'blk', 'cs', 'ethos', 'icn', 'mtl', 'pot', 'spank', 'vrsc', 'block', 'ctr', 'etn', 'icx', 'music', 'powr', 'sphtx', 'vtc', 'blz', 'ctxc', 'etp', 'ignis', 'mzc', 'ppc', 'srn', 'wabi', 'bnb', 'cvc', 'eur', 'ink', 'nano', 'ppp', 'stak', 'wan', 'bnt', 'dash', 'evx', 'ins', 'nas', 'ppt', 'start', 'waves', 'bnty', 'dat', 'exmo', 'ion', 'nav', 'prl', 'steem', 'wax'];

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
