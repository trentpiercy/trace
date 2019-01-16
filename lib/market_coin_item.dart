import 'package:flutter/material.dart';

import 'main.dart';
import 'market/coin_tabs.dart';

final assetImages = ['\$pac', 'bnt', 'dash', 'exmo', 'ion', 'nav', 'prl', 'steem', 'wan', '2give', 'bnty', 'dat', 'exp', 'iop', 'ncash', 'pungo', 'storj', 'waves', 'abt', 'booty', 'data', 'fair', 'iost', 'ndz', 'pura', 'storm', 'wax', 'act', 'bos', 'dbc', 'fct', 'iotx', 'nebl', 'qash', 'stq', 'wgr', 'actn', 'bpt', 'dcn', 'fil', 'iq', 'neo', 'qiwi', 'strat', 'wicc', 'ada', 'bq', 'dcr', 'fjc', 'itc', 'neos', 'qlc', 'sub', 'wings', 'add', 'brd', 'deez', 'fldc', 'jnt', 'neu', 'qrl', 'sumo', 'wpr', 'adx', 'bsd', 'dent', 'flo', 'jpy', 'nexo', 'qsp', 'sys', 'wtc', 'ae', 'bsv', 'dew', 'fsn', 'kcs', 'ngc', 'qtum', 'taas', 'x', 'aeon', 'btc', 'dgb', 'ftc', 'kin', 'nio', 'r', 'tau', 'xas', 'agi', 'btcd', 'dgd', 'fuel', 'kmd', 'nlc2', 'rads', 'tbx', 'xbc', 'agrs', 'btch', 'dlt', 'fun', 'knc', 'nlg', 'rap', 'tel', 'xby', 'aion', 'btcp', 'dnr', 'game', 'krb', 'nmc', 'rcn', 'ten', 'xcp', 'amb', 'btcz', 'dnt', 'gas', 'lbc', 'npxs', 'rdd', 'tern', 'xdn', 'amp', 'btdx', 'dock', 'gbp', 'lend', 'nuls', 'rdn', 'tghc', 'xem', 'ant', 'btg', 'doge', 'gbx', 'link', 'nxs', 'rep', 'theta', 'xin', 'apex', 'btm', 'drgn', 'gbyte', 'lkk', 'nxt', 'req', 'tix', 'xlm', 'appc', 'bts', 'drop', 'generic', 'loom', 'oax', 'rhoc', 'tkn', 'xmcc', 'ardr', 'btx', 'dta', 'glxt', 'lpt', 'ok', 'ric', 'tks', 'xmg', 'arg', 'burst', 'dth', 'gmr', 'lrc', 'omg', 'rise', 'tnb', 'xmo', 'ark', 'call', 'dtr', 'gno', 'lsk', 'omni', 'rlc', 'tnc', 'xmr', 'arn', 'cc', 'ebst', 'gnt', 'ltc', 'ong', 'rpx', 'tnt', 'xmy', 'ary', 'cdn', 'eca', 'gold', 'lun', 'ont', 'rub', 'tomo', 'xp', 'ast', 'cdt', 'edg', 'grc', 'maid', 'oot', 'rvn', 'tpay', 'xpa', 'atm', 'cenz', 'edo', 'grs', 'mana', 'ost', 'ryo', 'trig', 'xpm', 'audr', 'chain', 'edoge', 'gsc', 'mcap', 'ox', 'safe', 'trtl', 'xrp', 'auto', 'chat', 'ela', 'gto', 'mco', 'part', 'salt', 'trx', 'xsg', 'aywa', 'chips', 'elf', 'gup', 'mda', 'pasc', 'san', 'tusd', 'xtz', 'bab', 'cix', 'elix', 'gusd', 'mds', 'pasl', 'sbd', 'tzc', 'xuc', 'bat', 'clam', 'ella', 'gvt', 'med', 'pax', 'sberbank', 'ubq', 'xvc', 'bay', 'cloak', 'emc', 'gxlt', 'miota', 'pay', 'sc', 'unity', 'xvg', 'bcbc', 'cmm', 'emc2', 'gxs', 'mith', 'payx', 'shift', 'usd', 'xzc', 'bcc', 'cmt', 'eng', 'gzr', 'mkr', 'pgt', 'sib', 'usdc', 'yoyow', 'bcd', 'cnd', 'enj', 'hight', 'mln', 'pink', 'sky', 'usdt', 'zcl', 'bch', 'cnx', 'entrp', 'hodl', 'mnx', 'pirl', 'slr', 'utk', 'zec', 'bcn', 'cny', 'eos', 'hpb', 'mnz', 'pivx', 'sls', 'ven', 'zel', 'bco', 'cob', 'eql', 'hsr', 'moac', 'plr', 'smart', 'veri', 'zen', 'bcpt', 'colx', 'eqli', 'ht', 'mod', 'poa', 'sngls', 'vet', 'zest', 'bdl', 'coqui', 'equa', 'html', 'mona', 'poe', 'snm', 'via', 'zil', 'bela', 'cred', 'etc', 'huc', 'msr', 'polis', 'snt', 'vib', 'zilla', 'bix', 'crpt', 'eth', 'hush', 'mth', 'poly', 'soc', 'vibe', 'zrx', 'blcn', 'crw', 'ethos', 'icn', 'mtl', 'pot', 'spank', 'vivo', 'blk', 'cs', 'etn', 'icx', 'music', 'powr', 'sphtx', 'vrc', 'block', 'ctr', 'etp', 'ignis', 'mzc', 'ppc', 'srn', 'vrsc', 'blz', 'ctxc', 'eur', 'ink', 'nano', 'ppp', 'stak', 'vtc', 'bnb', 'cvc', 'evx', 'ins', 'nas', 'ppt', 'start', 'wabi'];

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
