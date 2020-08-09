import 'package:flutter/material.dart';
import 'main.dart';
import 'market/coin_tabs.dart';

final assetImages = ['\$pac', 'block', 'ctxc', 'ethos', 'hush', 'msr', 'pot', 'spank', 'vrc', '0xbtc', 'blz', 'cvc', 'etn', 'icn', 'mth', 'powr', 'sphtx', 'vrsc', '2give', 'bnb', 'd', 'etp', 'icx', 'mtl', 'ppc', 'srn', 'vtc', 'abt', 'bnt', 'dai', 'eur', 'ignis', 'music', 'ppp', 'stak', 'vtho', 'act', 'bnty', 'dash', 'evx', 'ilk', 'mzc', 'ppt', 'start', 'wabi', 'actn', 'booty', 'dat', 'exmo', 'ink', 'nano', 'pre', 'steem', 'wan', 'ada', 'bos', 'data', 'exp', 'ins', 'nas', 'prl', 'storj', 'waves', 'add', 'bpt', 'dbc', 'fair', 'ion', 'nav', 'pungo', 'storm', 'wax', 'adx', 'bq', 'dcn', 'fct', 'iop', 'ncash', 'pura', 'stq', 'wgr', 'ae', 'brd', 'dcr', 'fil', 'iost', 'ndz', 'qash', 'strat', 'wicc', 'aeon', 'bsd', 'deez', 'fjc', 'iotx', 'nebl', 'qiwi', 'sub', 'wings', 'aeur', 'bsv', 'dent', 'fldc', 'iq', 'neo', 'qlc', 'sumo', 'wpr', 'agi', 'btc', 'dew', 'flo', 'itc', 'neos', 'qrl', 'sys', 'wtc', 'agrs', 'btcd', 'dgb', 'fsn', 'jnt', 'neu', 'qsp', 'taas', 'x', 'aion', 'btch', 'dgd', 'ftc', 'jpy', 'nexo', 'qtum', 'tau', 'xas', 'amb', 'btcp', 'dlt', 'fuel', 'kcs', 'ngc', 'r', 'tbx', 'xbc', 'amp', 'btcz', 'dnr', 'fun', 'kin', 'nio', 'rads', 'tel', 'xbp', 'ant', 'btdx', 'dnt', 'game', 'kmd', 'nlc2', 'rap', 'ten', 'xby', 'apex', 'btg', 'dock', 'gas', 'knc', 'nlg', 'rcn', 'tern', 'xcp', 'appc', 'btm', 'doge', 'gbp', 'krb', 'nmc', 'rdd', 'tgch', 'xdn', 'ardr', 'bts', 'drgn', 'gbx', 'lbc', 'npxs', 'rdn', 'tghc', 'xem', 'arg', 'btt', 'drop', 'gbyte', 'lend', 'nuls', 'ren', 'theta', 'xin', 'ark', 'btx', 'dta', 'generic', 'link', 'nxs', 'rep', 'tix', 'xlm', 'arn', 'burst', 'dth', 'gin', 'lkk', 'nxt', 'req', 'tkn', 'xmcc', 'ary', 'call', 'dtr', 'glxt', 'loom', 'oax', 'rhoc', 'tks', 'xmg', 'ast', 'cc', 'ebst', 'gmr', 'lpt', 'ok', 'ric', 'tnb', 'xmo', 'atm', 'cdn', 'eca', 'gno', 'lrc', 'omg', 'rise', 'tnc', 'xmr', 'atom', 'cdt', 'edg', 'gnt', 'lsk', 'omni', 'rlc', 'tnt', 'xmy', 'audr', 'cenz', 'edo', 'gold', 'ltc', 'ong', 'rpx', 'tomo', 'xp', 'auto', 'chain', 'edoge', 'grc', 'lun', 'ont', 'rub', 'tpay', 'xpa', 'aywa', 'chat', 'ela', 'grin', 'maid', 'oot', 'rvn', 'trig', 'xpm', 'bab', 'chips', 'elec', 'grs', 'mana', 'ost', 'ryo', 'trtl', 'xrp', 'bat', 'cix', 'elf', 'gsc', 'mcap', 'ox', 'safe', 'trx', 'xsg', 'bay', 'clam', 'elix', 'gto', 'mco', 'part', 'salt', 'tusd', 'xtz', 'bcbc', 'cloak', 'ella', 'gup', 'mda', 'pasc', 'san', 'tzc', 'xuc', 'bcc', 'cmm', 'emc', 'gusd', 'mds', 'pasl', 'sbd', 'ubq', 'xvc', 'bcd', 'cmt', 'emc2', 'gvt', 'med', 'pax', 'sberbank', 'unity', 'xvg', 'bch', 'cnd', 'eng', 'gxlt', 'meetone', 'pay', 'sc', 'usd', 'xzc', 'bcio', 'cnx', 'enj', 'gxs', 'mft', 'payx', 'shift', 'usdc', 'yoyow', 'bcn', 'cny', 'entrp', 'gzr', 'miota', 'pgt', 'sib', 'usdt', 'zcl', 'bco', 'cob', 'eon', 'hight', 'mith', 'pink', 'sky', 'utk', 'zec', 'bcpt', 'colx', 'eop', 'hodl', 'mkr', 'pirl', 'slr', 'ven', 'zel', 'bdl', 'coqui', 'eos', 'hot', 'mln', 'pivx', 'sls', 'veri', 'zen', 'beam', 'cred', 'eql', 'hpb', 'mnx', 'plr', 'smart', 'vet', 'zest', 'bela', 'crpt', 'eqli', 'hsr', 'mnz', 'poa', 'sngls', 'via', 'zil', 'bix', 'crw', 'equa', 'ht', 'moac', 'poe', 'snm', 'vib', 'zilla', 'blcn', 'cs', 'etc', 'html', 'mod', 'polis', 'snt', 'vibe', 'zrx', 'blk', 'ctr', 'eth', 'huc', 'mona', 'poly', 'soc', 'vivo', 'sin', 'leo', 'klown', 'bze', 'ampl', 'matic', 'cag'];

class CoinListItem extends StatelessWidget {
  CoinListItem(this.snapshot, this.columnProps);
  final columnProps;
  final Map snapshot;

  _getImage() {
    if (assetImages.contains(snapshot["CoinInfo"]["Name"].toLowerCase())) {
      return new Image.asset(
          "assets/images/" + snapshot["CoinInfo"]["Name"].toLowerCase() + ".png",
          height: 28.0);
    } else {
      return new Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!snapshot.containsKey("CoinInfo") || !snapshot.containsKey("RAW") || snapshot == null || snapshot.isEmpty) {
      return new Container();
    }

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
                    new Text(snapshot["CoinInfo"]["Name"],
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
                                  snapshot["RAW"]["USD"]["MKTCAP"]),
                          style: Theme.of(context).textTheme.body2),
                      new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                      new Text(
                          "\$" +
                              normalizeNum(
                                  snapshot["RAW"]["USD"]["TOTALVOLUME24H"]),
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
                            snapshot["RAW"]["USD"]["PRICE"])),
                    new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                    new Text(
                        (snapshot["RAW"]["USD"]["CHANGEPCT24HOUR"] ?? 0) >= 0
                            ? "+" + (snapshot["RAW"]["USD"]["CHANGEPCT24HOUR"] ?? 0)
                                    .toStringAsFixed(2) + "%"
                            : (snapshot["RAW"]["USD"]["CHANGEPCT24HOUR"] ?? 0)
                                    .toStringAsFixed(2) + "%",
                        style: Theme.of(context).primaryTextTheme.body1.apply(
                            color: (snapshot["RAW"]["USD"]["CHANGEPCT24HOUR"] ?? 0) >= 0
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
