# ex00 設計方針 (01-design)

> Issue: #1
> Stage: 1/5 Architect
> Target: KotaSakatsume/mobileModule00 — `mobileModule00/ex00/`

## 0. 方針 (1行)
依存追加ゼロの素の Flutter プロジェクトを `mobileModule00/ex00/` に1本生成し、`MaterialApp` → 単一 `StatefulWidget` 画面で `Center` + `Column` の中央寄せレイアウトに `Text` と `ElevatedButton` を縦並びし、押下時に `debugPrint('Button pressed')` を出す。

## 1. ゴールとスコープ
- **ゴール**: Issue #1 の完成条件4項目を満たす、1ページ・1ボタンの最小 Flutter アプリ。
- **スコープに含む**:
  - `mobileModule00/ex00/` への Flutter プロジェクト雛形生成。
  - `lib/main.dart` 単一ファイルへのアプリ実装(中央寄せ Text + Button)。
  - ボタン押下で debug console に `Button pressed` を出力。
  - phone/tablet/回転で崩れない中央寄せレイアウト。
  - `flutter analyze` がクリーンになる状態。
- **このPRの単位**: 1つのPRで完結(雛形 + `lib/main.dart` + 不要ファイル整理)。想定変更は実質 `lib/main.dart` の1ファイル(数十行)。

## 2. やらないこと (Non-goals)
1. **状態管理ライブラリ・ルーティング・テーマ設計の導入はしない**(Provider/Riverpod/go_router 等は ex00 では過剰。後続 ex で必要になれば別途)。
2. **ウィジェット/ユニットテスト(`test/`)の作成はしない**(Issue のテスト観点は手動 + `flutter analyze` で検証。CI整備も別PR)。
3. **実機/エミュレータでの動作キャプチャ・スクショ取得・CI構築はこの設計段階のスコープ外**(検証は Reviewer 段階で `flutter analyze` + 任意の手動起動。SDK前提は §8 参照)。

## 3. 技術選定（Flutterバージョン方針 / 依存追加なし方針）
- **Flutter SDK**: ローカルにインストール済みの安定版 (stable channel) をそのまま使用。バージョンを `pubspec.yaml` で過度にピン留めせず、`environment.sdk` は `flutter create` 生成のデフォルト制約をそのまま採用。→ Piscine 採点機の環境差異に弱くしない。
- **依存追加なし方針**: `flutter/material.dart` のみ使用。`pubspec.yaml` の `dependencies` は Flutter SDK のみ、追加パッケージゼロ。`cupertino_icons` は雛形デフォルトのまま放置でよい。
- **UIキット**: Material を採用(`ElevatedButton` が標準で揃い、`flutter create` デフォルトと整合)。Cupertino は不採用。
- **生成コマンド方針(Implementer向け)**: `flutter create` で `ex00` ディレクトリを生成 → `lib/main.dart` を本設計に沿って全面置換。プラットフォームフォルダは生成物のまま残す。

## 4. ディレクトリ・ファイル構成（想定ツリー）
```
mobileModule00/
└── ex00/
    ├── lib/
    │   └── main.dart        ← 実装の本体(ここだけ手で書く)
    ├── pubspec.yaml         ← 依存追加なし。雛形のまま
    ├── analysis_options.yaml← 雛形の flutter_lints をそのまま使用
    ├── android/ ios/ web/   ← flutter create 生成物。原則ノータッチ
    └── test/                ← 生成されるが本exでは中身を足さない
```
- 触るのは実質 `lib/main.dart` のみ。その他は `flutter create` 生成のまま。

## 5. ウィジェット構成方針
- **StatefulWidget を採用**(却下案: StatelessWidget)。
  - 採用理由: ボタン押下イベントハンドラを持ち、後続 ex で状態が乗ることを見越し `State` を持たせるのが自然。
  - ※「依存なし・最小」を最優先するなら Stateless でも可。Implementer は StatefulWidget で実装し、迷えば Stateless にフォールバック可。
- **構成ツリー**:
  ```
  MaterialApp
   └─ Scaffold
       └─ Center
           └─ Column(mainAxisAlignment: center)
               ├─ Text('...')
               ├─ SizedBox(height: 任意の間隔)
               └─ ElevatedButton(onPressed: ..., child: Text('...'))
  ```
- **中央寄せ**: 水平=`Center` + `Column` デフォルト、垂直=`Column(mainAxisAlignment: MainAxisAlignment.center)`。
- **レスポンシブ**: 固定 px 配置を避けフレックス配置に委ねる。`MediaQuery` 分岐は ex00 では不要。

## 6. ログ出力方針（debugPrint vs print）
- **`debugPrint('Button pressed')` を採用**。`print` は `avoid_print` lint で警告になり得るため不採用。
- UI には一切出さない。出力先は console のみ。文言は完全一致で `Button pressed`。

## 7. 受け入れ基準（検証可能な形）
| # | 完成条件 | 検証方法 |
|---|---------|---------|
| AC1 | Text と Button が画面中央に縦に並ぶ | 起動目視 / `Center`>`Column(center)` をコードレビュー |
| AC2 | ボタン押下で console に `Button pressed` | 押下後 console に完全一致で1行出力(`debugPrint`) |
| AC3 | 回転・異サイズでレイアウト非破綻 | phone縦/横・tablet で中央維持。固定座標不使用を確認 |
| AC4 | `flutter analyze` がクリーン | warning/info ゼロ。`print` 不使用を確認 |
| AC5 | クラッシュしない | 起動〜ボタン連打で例外なし |

## 8. リスク・前提
- **前提**: ローカルに Flutter SDK (stable) がセットアップ済みで `flutter create` / `flutter analyze` 実行可能。→ **未セットアップの可能性が高い**。Investigator 段階で `flutter --version` の存在確認を最初に行う。無ければ「環境構築は別タスク」として切り出す。
- **リスク1**: SDK バージョン差で生成 `analysis_options.yaml` の lint が変わり予期せぬ info が出る可能性 → analyze 結果を見て個別対応。
- **リスク2**: `flutter create` がプラットフォームフォルダを大量生成し PR が膨らむ → Reviewer には `lib/main.dart` のみ精査でよい旨を申し送り。
- **スコープ外と確定**: 実機/エミュレータ実行確認は必須としない。`flutter analyze` クリーン + コードレビューでの中央寄せ・debugPrint 確認を合否基準とする。

---
**次段(Investigator)への申し送り**: 最初に `flutter --version` で SDK 有無を確認 → 無い場合は環境構築タスクとして分離提案。SDK があれば `flutter create` の正しい実行パスと、デフォルト lint セット内容を確認すること。
