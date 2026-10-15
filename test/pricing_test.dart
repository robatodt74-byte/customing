import 'package:customing/pricing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('vehicle prices and tax are not taxed twice', () {
    expect(priceTotals(selectedPrices('rebel250', 'normal', false, false)), (
      gross: 638000,
      net: 580000,
      tax: 58000,
    ));
    expect(priceTotals(selectedPrices('vstrom250', 'normal', false, false)), (
      gross: 685300,
      net: 623000,
      tax: 62300,
    ));
  });

  test('case pair is added once, and selected titanium changes by bike', () {
    expect(priceTotals(selectedPrices('rebel250', 'titanium', true, true)), (
      gross: 743600,
      net: 676000,
      tax: 67600,
    ));
    expect(priceTotals(selectedPrices('vstrom250', 'titanium', true, true)), (
      gross: 841500,
      net: 765000,
      tax: 76500,
    ));
  });

  test('CB223S keeps historical 5 percent tax alongside 10 percent parts', () {
    expect(priceTotals(selectedPrices('cb223s', 'normal', true, true)), (
      gross: 529950,
      net: 502000,
      tax: 27950,
    ));
  });

  test('unverified prices remain unknown rather than free parts', () {
    final items = selectedPrices('cb223s', 'titanium', false, false);
    expect(items.where((item) => item.gross == null), hasLength(2));
    expect(priceTotals(items).gross, 467250);
    expect(selectedPrices('rebel250', 'up', true, false)[1].gross, isNull);
    expect(yen(743600), '743,600 円');
  });
}
