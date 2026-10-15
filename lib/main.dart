import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pricing.dart';

void main() => runApp(const CustomingApp());

const tankColors = {
  'black': (label: '黒', color: Color(0xFF242424)),
  'white': (label: '白', color: Color(0xFFFFFFFF)),
  'silver': (label: 'シルバー', color: Color(0xFFADB2BA)),
  'red': (label: '赤', color: Color(0xFFE53935)),
  'blue': (label: '青', color: Color(0xFF1565C0)),
  'yellow': (label: '黄', color: Color(0xFFFFD600)),
  'green': (label: '緑', color: Color(0xFF248445)),
  'orange': (label: 'オレンジ', color: Color(0xFFEF6C00)),
};
const exhaustLabels = {'normal': 'normal', 'titanium': 'チタン', 'up': 'アップ'};

const bikeModels = {
  'cb223s': (label: 'CB223S', manifest: 'assets/bike/manifest.json'),
  'vstrom250': (
    label: 'V-Strom 250',
    manifest: 'assets/bike/vstrom/manifest.json',
  ),
  'rebel250': (label: 'Rebel 250', manifest: 'assets/bike/rebel/manifest.json'),
};

class BikeCustomization {
  String tank = 'black';
  String exhaust = 'normal';
  bool rearBox = false;
  bool sideBox = false;
}

class CustomingApp extends StatelessWidget {
  const CustomingApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'バイクカスタム',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      scaffoldBackgroundColor: const Color(0xFFFFF8FC),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFFFF8FC),
        selectedColor: const Color(0xFFE8DEF8),
        checkmarkColor: const Color(0xFF494154),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF494154)),
      ),
    ),
    home: const CustomingPage(),
  );
}

class CustomingPage extends StatefulWidget {
  const CustomingPage({super.key});

  @override
  State<CustomingPage> createState() => _CustomingPageState();
}

class _CustomingPageState extends State<CustomingPage> {
  String model = 'cb223s';
  final configurations = {
    for (final key in bikeModels.keys) key: BikeCustomization(),
  };
  BikeCustomization get current => configurations[model]!;
  String get tank => current.tank;
  set tank(String value) => current.tank = value;
  String get exhaust => current.exhaust;
  set exhaust(String value) => current.exhaust = value;
  bool get rearBox => current.rearBox;
  set rearBox(bool value) => current.rearBox = value;
  bool get sideBox => current.sideBox;
  set sideBox(bool value) => current.sideBox = value;
  late Future<Map<String, dynamic>> manifest = loadManifest();

  Future<Map<String, dynamic>> loadManifest() async =>
      jsonDecode(await rootBundle.loadString(bikeModels[model]!.manifest))
          as Map<String, dynamic>;

  Widget choice(
    String group,
    String value,
    String label,
    bool selected,
    VoidCallback onTap, {
    Color? swatch,
  }) => ChoiceChip(
    key: ValueKey('$group-$value'),
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (swatch != null) ...[
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: swatch,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF8B8491)),
            ),
          ),
          const SizedBox(width: 7),
        ],
        Text(label),
      ],
    ),
    selected: selected,
    showCheckmark: true,
    side: selected
        ? BorderSide.none
        : const BorderSide(color: Color(0xFFCAC4D0)),
    onSelected: (_) => setState(onTap),
  );

  Widget section(
    String title,
    List<Widget> children, {
    bool vertical = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14)),
        if (vertical)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          )
        else
          Wrap(spacing: 6, runSpacing: 0, children: children),
      ],
    ),
  );

  Widget priceSummary() {
    final items = selectedPrices(model, exhaust, rearBox, sideBox);
    final total = priceTotals(items);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),
        const Divider(),
        const Text('価格の内訳（税込）', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(item.label, style: const TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Text(
                  item.gross == null ? '要見積' : yen(item.gross!),
                  style: TextStyle(
                    fontSize: 13,
                    color: item.gross == null
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Text(
          '税抜 ${yen(total.net)} ／ 消費税 ${yen(total.tax)}',
          key: const ValueKey('price-tax'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          '参考合計 ${yen(total.gross)}',
          key: const ValueKey('price-total'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28),
        ),
        const Text(
          '確認済みの車両・部品価格のみ',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 10),
        const Text(
          '塗装・要見積の部品・取付金具・工賃・送料・登録諸費用・保険は未計上。部品は参考製品の価格で、画像と商品の形状は一致しません。',
          key: ValueKey('price-exclusions'),
          style: TextStyle(fontSize: 12, height: 1.6),
        ),
        if (model == 'cb223s')
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'CB223Sは2008年当時の車両価格（税込5%）と現在の部品価格（税込10%）を合算した参考値です。現在の新車見積ではありません。',
              style: TextStyle(fontSize: 12, height: 1.6),
            ),
          ),
        const SizedBox(height: 6),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text('価格の出典・対象商品', style: TextStyle(fontSize: 13)),
          subtitle: const Text(
            '確認日：2026年10月15日',
            style: TextStyle(fontSize: 11),
          ),
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      item.note,
                      style: const TextStyle(fontSize: 12, height: 1.5),
                    ),
                    if (item.url.isNotEmpty)
                      SelectableText(
                        item.url,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6750A4),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 528),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text('バイクカスタム', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(height: 18),
                  section('バイクの種類', [
                    for (final entry in bikeModels.entries)
                      choice(
                        'model',
                        entry.key,
                        entry.value.label,
                        model == entry.key,
                        () {
                          model = entry.key;
                          manifest = loadManifest();
                        },
                      ),
                  ]),
                  Semantics(
                    label:
                        '${tankColors[tank]!.label}の${bikeModels[model]!.label}、'
                        '${exhaustLabels[exhaust]}マフラー、'
                        'リアボックス${rearBox ? '有' : '無'}、'
                        'サイドボックス${sideBox ? '有' : '無'}',
                    image: true,
                    child: ExcludeSemantics(
                      child: FutureBuilder<Map<String, dynamic>>(
                        key: ValueKey(model),
                        future: manifest,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return SizedBox(
                              height: 220,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('バイク画像を読み込めませんでした'),
                                    TextButton(
                                      onPressed: () => setState(() {
                                        manifest = loadManifest();
                                      }),
                                      child: const Text('再読み込み'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 220,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final assets =
                              snapshot.data!['assets'] as Map<String, dynamic>;
                          final visible = [
                            'chassis',
                            'tank-$tank',
                            'exhaust-$exhaust',
                            if (sideBox) 'side-box',
                            if (rearBox) 'rear-box',
                          ];
                          return AspectRatio(
                            aspectRatio: 3 / 2,
                            child: LayoutBuilder(
                              builder: (context, constraints) => Stack(
                                children: [
                                  for (final name in visible)
                                    Positioned(
                                      left:
                                          assets[name]['x'] /
                                          1536 *
                                          constraints.maxWidth,
                                      top:
                                          assets[name]['y'] /
                                          1024 *
                                          constraints.maxHeight,
                                      width:
                                          constraints.maxWidth *
                                          assets[name]['scale'],
                                      height:
                                          constraints.maxHeight *
                                          assets[name]['scale'],
                                      child: ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          assets[name]['tint'] == true
                                              ? (tank == 'black'
                                                    ? const Color(0xFF50555C)
                                                    : tankColors[tank]!.color)
                                              : Colors.white,
                                          BlendMode.modulate,
                                        ),
                                        child: Image.asset(
                                          assets[name]['file'] as String,
                                          key: ValueKey('image-$model-$name'),
                                          fit: BoxFit.contain,
                                          gaplessPlayback: true,
                                          errorBuilder: (_, _, _) =>
                                              const Center(
                                                child: Icon(
                                                  Icons.broken_image_outlined,
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  section('マフラーを選ぶ', [
                    for (final entry in exhaustLabels.entries)
                      choice(
                        'exhaust',
                        entry.key,
                        entry.value,
                        exhaust == entry.key,
                        () => exhaust = entry.key,
                      ),
                  ], vertical: true),
                  section('リアボックス', [
                    choice(
                      'rear',
                      'none',
                      '無',
                      !rearBox,
                      () => rearBox = false,
                    ),
                    choice('rear', 'box', '有', rearBox, () => rearBox = true),
                  ]),
                  section('サイドボックス', [
                    choice(
                      'side',
                      'none',
                      '無',
                      !sideBox,
                      () => sideBox = false,
                    ),
                    choice('side', 'box', '有', sideBox, () => sideBox = true),
                  ]),
                  section('タンクカラー（全8色）', [
                    for (final entry in tankColors.entries)
                      choice(
                        'tank',
                        entry.key,
                        entry.value.label,
                        tank == entry.key,
                        () => tank = entry.key,
                        swatch: entry.value.color,
                      ),
                  ]),
                  const Divider(height: 28),
                  Text(
                    '車種：${bikeModels[model]!.label}\n'
                    'タンク：${tankColors[tank]!.label}　'
                    'マフラー：${exhaustLabels[exhaust]}\n'
                    'リアボックス：${rearBox ? '有' : '無'}　'
                    'サイドボックス：${sideBox ? '有' : '無'}',
                    key: const ValueKey('selection-summary'),
                    style: const TextStyle(fontSize: 13, height: 1.8),
                  ),
                  priceSummary(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
