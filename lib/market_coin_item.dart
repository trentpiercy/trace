import 'package:flutter/material.dart';

import 'main.dart';
import 'market/coin_tabs.dart';

final assetImages = ['\$pac.png', 'block.png', 'ctxc.png', 'ethos.png', 'hush.png', 'msr.png', 'pot.png', 'spank.png', 'vrc.png', '0xbtc.png', 'blz.png', 'cvc.png', 'etn.png', 'icn.png', 'mth.png', 'powr.png', 'sphtx.png', 'vrsc.png', '2give.png', 'bnb.png', 'd.png', 'etp.png', 'icx.png', 'mtl.png', 'ppc.png', 'srn.png', 'vtc.png', 'abt.png', 'bnt.png', 'dai.png', 'eur.png', 'ignis.png', 'music.png', 'ppp.png', 'stak.png', 'vtho.png', 'act.png', 'bnty.png', 'dash.png', 'evx.png', 'ilk.png', 'mzc.png', 'ppt.png', 'start.png', 'wabi.png', 'actn.png', 'booty.png', 'dat.png', 'exmo.png', 'ink.png', 'nano.png', 'pre.png', 'steem.png', 'wan.png', 'ada.png', 'bos.png', 'data.png', 'exp.png', 'ins.png', 'nas.png', 'prl.png', 'storj.png', 'waves.png', 'add.png', 'bpt.png', 'dbc.png', 'fair.png', 'ion.png', 'nav.png', 'pungo.png', 'storm.png', 'wax.png', 'adx.png', 'bq.png', 'dcn.png', 'fct.png', 'iop.png', 'ncash.png', 'pura.png', 'stq.png', 'wgr.png', 'ae.png', 'brd.png', 'dcr.png', 'fil.png', 'iost.png', 'ndz.png', 'qash.png', 'strat.png', 'wicc.png', 'aeon.png', 'bsd.png', 'deez.png', 'fjc.png', 'iotx.png', 'nebl.png', 'qiwi.png', 'sub.png', 'wings.png', 'aeur.png', 'bsv.png', 'dent.png', 'fldc.png', 'iq.png', 'neo.png', 'qlc.png', 'sumo.png', 'wpr.png', 'agi.png', 'btc.png', 'dew.png', 'flo.png', 'itc.png', 'neos.png', 'qrl.png', 'sys.png', 'wtc.png', 'agrs.png', 'btcd.png', 'dgb.png', 'fsn.png', 'jnt.png', 'neu.png', 'qsp.png', 'taas.png', 'x.png', 'aion.png', 'btch.png', 'dgd.png', 'ftc.png', 'jpy.png', 'nexo.png', 'qtum.png', 'tau.png', 'xas.png', 'amb.png', 'btcp.png', 'dlt.png', 'fuel.png', 'kcs.png', 'ngc.png', 'r.png', 'tbx.png', 'xbc.png', 'amp.png', 'btcz.png', 'dnr.png', 'fun.png', 'kin.png', 'nio.png', 'rads.png', 'tel.png', 'xbp.png', 'ant.png', 'btdx.png', 'dnt.png', 'game.png', 'kmd.png', 'nlc2.png', 'rap.png', 'ten.png', 'xby.png', 'apex.png', 'btg.png', 'dock.png', 'gas.png', 'knc.png', 'nlg.png', 'rcn.png', 'tern.png', 'xcp.png', 'appc.png', 'btm.png', 'doge.png', 'gbp.png', 'krb.png', 'nmc.png', 'rdd.png', 'tgch.png', 'xdn.png', 'ardr.png', 'bts.png', 'drgn.png', 'gbx.png', 'lbc.png', 'npxs.png', 'rdn.png', 'tghc.png', 'xem.png', 'arg.png', 'btt.png', 'drop.png', 'gbyte.png', 'lend.png', 'nuls.png', 'ren.png', 'theta.png', 'xin.png', 'ark.png', 'btx.png', 'dta.png', 'generic.png', 'link.png', 'nxs.png', 'rep.png', 'tix.png', 'xlm.png', 'arn.png', 'burst.png', 'dth.png', 'gin.png', 'lkk.png', 'nxt.png', 'req.png', 'tkn.png', 'xmcc.png', 'ary.png', 'call.png', 'dtr.png', 'glxt.png', 'loom.png', 'oax.png', 'rhoc.png', 'tks.png', 'xmg.png', 'ast.png', 'cc.png', 'ebst.png', 'gmr.png', 'lpt.png', 'ok.png', 'ric.png', 'tnb.png', 'xmo.png', 'atm.png', 'cdn.png', 'eca.png', 'gno.png', 'lrc.png', 'omg.png', 'rise.png', 'tnc.png', 'xmr.png', 'atom.png', 'cdt.png', 'edg.png', 'gnt.png', 'lsk.png', 'omni.png', 'rlc.png', 'tnt.png', 'xmy.png', 'audr.png', 'cenz.png', 'edo.png', 'gold.png', 'ltc.png', 'ong.png', 'rpx.png', 'tomo.png', 'xp.png', 'auto.png', 'chain.png', 'edoge.png', 'grc.png', 'lun.png', 'ont.png', 'rub.png', 'tpay.png', 'xpa.png', 'aywa.png', 'chat.png', 'ela.png', 'grin.png', 'maid.png', 'oot.png', 'rvn.png', 'trig.png', 'xpm.png', 'bab.png', 'chips.png', 'elec.png', 'grs.png', 'mana.png', 'ost.png', 'ryo.png', 'trtl.png', 'xrp.png', 'bat.png', 'cix.png', 'elf.png', 'gsc.png', 'mcap.png', 'ox.png', 'safe.png', 'trx.png', 'xsg.png', 'bay.png', 'clam.png', 'elix.png', 'gto.png', 'mco.png', 'part.png', 'salt.png', 'tusd.png', 'xtz.png', 'bcbc.png', 'cloak.png', 'ella.png', 'gup.png', 'mda.png', 'pasc.png', 'san.png', 'tzc.png', 'xuc.png', 'bcc.png', 'cmm.png', 'emc.png', 'gusd.png', 'mds.png', 'pasl.png', 'sbd.png', 'ubq.png', 'xvc.png', 'bcd.png', 'cmt.png', 'emc2.png', 'gvt.png', 'med.png', 'pax.png', 'sberbank.png', 'unity.png', 'xvg.png', 'bch.png', 'cnd.png', 'eng.png', 'gxlt.png', 'meetone.png', 'pay.png', 'sc.png', 'usd.png', 'xzc.png', 'bcio.png', 'cnx.png', 'enj.png', 'gxs.png', 'mft.png', 'payx.png', 'shift.png', 'usdc.png', 'yoyow.png', 'bcn.png', 'cny.png', 'entrp.png', 'gzr.png', 'miota.png', 'pgt.png', 'sib.png', 'usdt.png', 'zcl.png', 'bco.png', 'cob.png', 'eon.png', 'hight.png', 'mith.png', 'pink.png', 'sky.png', 'utk.png', 'zec.png', 'bcpt.png', 'colx.png', 'eop.png', 'hodl.png', 'mkr.png', 'pirl.png', 'slr.png', 'ven.png', 'zel.png', 'bdl.png', 'coqui.png', 'eos.png', 'hot.png', 'mln.png', 'pivx.png', 'sls.png', 'veri.png', 'zen.png', 'beam.png', 'cred.png', 'eql.png', 'hpb.png', 'mnx.png', 'plr.png', 'smart.png', 'vet.png', 'zest.png', 'bela.png', 'crpt.png', 'eqli.png', 'hsr.png', 'mnz.png', 'poa.png', 'sngls.png', 'via.png', 'zil.png', 'bix.png', 'crw.png', 'equa.png', 'ht.png', 'moac.png', 'poe.png', 'snm.png', 'vib.png', 'zilla.png', 'blcn.png', 'cs.png', 'etc.png', 'html.png', 'mod.png', 'polis.png', 'snt.png', 'vibe.png', 'zrx.png', 'blk.png', 'ctr.png', 'eth.png', 'huc.png', 'mona.png', 'poly.png', 'soc.png', 'vivo.png'];

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
