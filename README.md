# customing

CB223S / V-Strom 250 / Rebel 250 のバイクカスタムを選べるFlutter Webアプリです。
添付された屋台注文アプリを参考に、標準ChoiceChipで選択項目を表示します。

- 車種：CB223S / V-Strom 250 / Rebel 250
- マフラー：normal / チタン / アップ（1つ選択）
- リアボックス：無 / 有
- サイドボックス：無 / 有
- タンク：黒 / 白 / シルバー / 赤 / 青 / 黄 / 緑 / オレンジ

選択中はチェックと薄紫の背景を表示し、中央のバイク画像と下部の選択内容を更新します。
画面を開いている間は、各車種のカスタム内容を独立して保持します。車種を行き来しても選択は戻ります。再読み込みすると初期設定になります。

## 起動

```sh
cd /Users/uedatoma/Documents/ChatGPT/雑用/customing
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 53112
```

同じポートで確認用サーバーが実行中の場合は、先にそのサーバーを停止するか、別のポートを指定してください。

## ビルドと検証

```sh
dart analyze --format machine lib test
flutter test
flutter build web --no-web-resources-cdn
python3 -m http.server 53112 --bind 127.0.0.1 --directory build/web
```

実装は `lib/main.dart`、既存の透過PNGと重ね合わせ設定は `assets/bike/`、追加車種の素材は `assets/bike/vstrom/` と `assets/bike/rebel/` にあります。
追加車種のタンクは白い素材を実行時に着色します。共通のカスタムマフラーとボックスは車種別の配置設定で重ねています。
画像生成の条件・参照は `assets/bike/illustration-lineage.json` に保存しています。
元画像は親フォルダの `assets/cb223s/` に保存したままです。

検証：Dart静的解析、13件のテスト（Widget・価格計算）、Webビルドが成功。
ブラウザでパーツ切り替えと320px幅の表示を確認しました。
`flutter analyze` はSDK解析サーバーのJSON通信エラーで終了したため、上記の直接Dart解析を使用しています。

## 参考価格

下部に選択した車両・部品の税込内訳、税抜額、消費税と参考合計を表示します。出典と対象商品は画面内で展開できます。価格データは `lib/pricing.dart` にまとめています（確認日：2026-10-15）。

CB223Sは2008年の発売時価格と当時の消費税5%を使用しています。現在の新車見積ではありません。V-Strom 250とRebel 250はメーカー掲載価格です。部品は参考製品の価格で、車種適合や画像の形状を保証するものではありません。未確認のマフラー・塗装は「要見積」、取付金具・工賃・送料・登録諸費用・保険は未計上です。

## 公開

アプリ: https://robatodt74-byte.github.io/customing/

ソース: https://github.com/robatodt74-byte/customing

`main`へのpushでGitHub Actionsが静的解析、テスト、Flutter Webビルドを実行し、成功した成果物をGitHub Pagesに公開します。手動再実行はActionsの「Deploy Flutter Web to GitHub Pages」から行えます。

```sh
flutter build web --base-href /customing/ --no-web-resources-cdn
```

配信対象には利用中の画像とmanifestのみを含め、生成履歴や参照画像は含めません。画像のテイスト統一は次の改訂で対応予定です。
