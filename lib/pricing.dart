class PriceItem {
  const PriceItem(this.label, this.gross, this.net, this.note, [this.url = '']);
  final String label;
  final int? gross;
  final int? net;
  final String note;
  final String url;
}

const vehiclePrices = {
  'cb223s': PriceItem(
    'CB223S 車両本体',
    467250,
    445000,
    '2008年発売時・ストライプタイプ。当時の消費税5%を含む参考価格。現在の新車販売価格ではありません。',
    'https://global.honda/jp/news/2008/2080321-cb223s.html',
  ),
  'vstrom250': PriceItem(
    'V-Strom 250 車両本体',
    685300,
    623000,
    '現行掲載モデル・メーカー希望小売価格（消費税10%込み）。',
    'https://www1.suzuki.co.jp/motor/lineup/dl250rljm6/?page=style',
  ),
  'rebel250': PriceItem(
    'Rebel 250 車両本体',
    638000,
    580000,
    '標準モデル・メーカー希望小売価格（E-Clutchを除く／消費税10%込み）。',
    'https://www.honda.co.jp/Rebel250/',
  ),
};
const titaniumPrices = {
  'cb223s': PriceItem('チタンマフラー', null, null, '該当製品の価格未確認。別途見積。'),
  'vstrom250': PriceItem(
    'チタンマフラー',
    93500,
    85000,
    '参考：ヨシムラ R-77S STBC（110-130-5W80B）。メーカー掲載適合は2017〜2025年、2026年の適合は未確認。',
    'https://www.yoshimura-jp.com/product/n-118532',
  ),
  'rebel250': PriceItem(
    'チタンマフラー',
    42900,
    39000,
    '参考：LCIPARTS ショートチタン（2023〜2026年向け掲載）。公式オンライン特価・送料別。',
    'https://www.lci-parts.com/products/lciexst-ho-rebel-23',
  ),
};
const rearCasePrice = PriceItem(
  'リアボックス',
  26400,
  24000,
  '参考：GIVI E43NTL・43L。ケース本体価格。キャリア・取付金具の費用と車種適合は別途確認。',
  'https://www.daytona.co.jp/products/detail/95339/',
);
const sideCasePrice = PriceItem(
  'サイドボックス',
  36300,
  33000,
  '参考：GIVI E22N・22L左右セット。専用ホルダーは別売、車種適合は別途確認。',
  'https://www.daytona.co.jp/products/detail/90668/',
);

List<PriceItem> selectedPrices(
  String model,
  String exhaust,
  bool rear,
  bool side,
) => [
  vehiclePrices[model]!,
  if (exhaust == 'normal')
    const PriceItem('normalマフラー', 0, 0, '車両の標準装備に含む。追加費用なし。')
  else if (exhaust == 'titanium')
    titaniumPrices[model]!
  else
    const PriceItem('アップマフラー', null, null, '車種に適合する製品・加工費用は別途見積。'),
  if (rear) rearCasePrice,
  if (side) sideCasePrice,
  const PriceItem(
    'タンク塗装・外装変更',
    null,
    null,
    '8色は見た目のプレビュー。純正色の設定とは連動しません。追加塗装は色・下地・外装点数により別途見積。',
  ),
];

({int gross, int net, int tax}) priceTotals(List<PriceItem> items) {
  final gross = items.fold(0, (sum, item) => sum + (item.gross ?? 0));
  final net = items.fold(0, (sum, item) => sum + (item.net ?? 0));
  return (gross: gross, net: net, tax: gross - net);
}

String yen(int amount) =>
    '${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')} 円';
