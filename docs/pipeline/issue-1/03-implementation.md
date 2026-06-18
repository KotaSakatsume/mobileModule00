# ex00 実装サマリー (03-implementation)

> Issue: #1
> Stage: 3/5 Implementer
> Branch: pipeline/issue-1

## 1. 作成・変更したファイル一覧(パスと役割)
- `mobileModule00/ex00/` 一式 — `flutter create ex00`(`--empty` 無し)で新規生成。130 ファイル。
- `mobileModule00/ex00/lib/main.dart` — 設計通りに全面差し替え。アプリ本体(中央寄せ Text + ElevatedButton、押下で `debugPrint('Button pressed')`)。
- `mobileModule00/ex00/test/widget_test.dart` — 雛形のカウンターアプリ前提テストを、新 UI に合わせた最小 widget テストへ書き換え(差し替えないと `flutter test` が失敗するため)。
- 上記以外(`pubspec.yaml` / `analysis_options.yaml` / `android` / `ios` / `web` 等)は生成物のまま無変更。lint include も未変更。

## 2. lib/main.dart の設計対応(どの AC をどう満たしたか)
- **AC1(Text と Button が画面中央に縦並び)**: `MaterialApp → Scaffold → Center → Column(mainAxisAlignment: MainAxisAlignment.center)` に `Text('A basic display')` → `SizedBox(height: 16)` → `ElevatedButton`。水平中央=`Center`、垂直中央=`Column(center)`。
- **AC2(押下で console に `Button pressed`)**: `onPressed: () => debugPrint('Button pressed')`。文言完全一致、UI には出さない。test 実行ログにも `Button pressed` が1行出力されたことを確認。
- **AC3(回転・異サイズで非破綻)**: 固定 px 座標を使わず Center/Column のフレックス配置に委譲。`MediaQuery` 分岐なし(設計通り不要)。
- **AC4(`flutter analyze` クリーン)**: `debugPrint` 採用で `avoid_print` 回避。`No issues found!`。
- **AC5(クラッシュしない)**: 起動〜タップで例外なし(widget テストの `takeException()` が `null`)。
- ウィジェット種別: 設計第一候補の **StatefulWidget** を採用(`MyApp` を StatefulWidget 化、状態は未保持で後続 ex 拡張余地のみ確保)。import は `package:flutter/material.dart` のみ。追加依存ゼロ。

## 3. widget_test.dart の内容(何を検証するか)
最小の 2 ケース:
1. `Displays initial text and button` — 起動時に `find.text('A basic display')` が 1 個、`find.byType(ElevatedButton)` が 1 個表示されること。
2. `Tapping the button does not throw` — ボタンをタップ→`pump()` 後に `tester.takeException()` が `null`(例外なし)。
debugPrint 文言の検証は行わない(指示通り最小)。

## 4. 検証結果(実際のコマンド出力の引用)
作業ディレクトリ: `mobileModule00/ex00`

`dart format lib/main.dart test/widget_test.dart`:
```
Formatted 2 files (0 changed) in 1.48 seconds.
```

`flutter analyze`:
```
Analyzing ex00...
No issues found! (ran in 78.7s)
```

`flutter test`(抜粋):
```
00:54 +1: Displays initial text and button
00:54 +1: Tapping the button does not throw
Button pressed
00:55 +2: Tapping the button does not throw
00:55 +2: All tests passed!
```
→ analyze クリーン / 全テスト通過 / タップ時に `Button pressed` 出力を確認。

## 5. 設計との差分・判断したこと
- **概ね設計通り。** 1 点だけスコープ追加: 01-design 「Non-goal: テスト作成はしない」に対し、02-research の補足どおり `flutter create` が生成する `test/widget_test.dart` が新 main.dart と不整合で `flutter test` を破壊するため、本タスク指示に従い**新 UI に合わせた最小テストへ書き換え**た(新規テスト機能の追加ではなく既存生成物の整合修正)。
- Text/Button の表示文言は設計で「任意」とされていたため `A basic display` / `Click me` を採用。
- `debugPrint` は release でも出力される(02-research の事実訂正)が、課題は console 出力が目的で `kDebugMode` ガードは設計外のため**入れない**判断(勝手に意図を仮定しない)。

## 6. 後段(Reviewer)への申し送り
- 精査対象は実質 `mobileModule00/ex00/lib/main.dart` と `test/widget_test.dart` の 2 ファイルのみ。それ以外は `flutter create` 生成物そのまま(差分が膨らむが原則ノータッチ、リスク2の通り)。
- `analysis_options.yaml` の lint include は未変更(`avoid_print: false` 等の逃げ無し)。
- `git commit`/`push` は未実施(後段 Integrator 担当)。`flutter upgrade`/`channel` も未実行(channel が user-branch のため、リスク3遵守)。

## リスク箇所3件への対応(02-research §6)
- **リスク1(debugPrint はリリースで消えるという思い込み)**: 思い込みに依拠せず、課題意図=console 出力として `debugPrint` をガード無しで採用。`kDebugMode` 等の独自仮定は入れていない。
- **リスク2(うっかり print → analyze warning / lint 無効化の逃げ)**: `print` は不使用、`debugPrint` で実装。`analysis_options.yaml` は無変更。`flutter analyze` = No issues found で実証。
- **リスク3(channel が user-branch、upgrade/channel で失敗)**: SDK を一切触らず、`flutter create` / `analyze` / `test` のみ実行。`flutter upgrade`・`flutter channel` は未実行。

---

## 追補(段階4差し戻し後 / should 2件 取り込み)
レビュー should 2件を取り込み、`test/widget_test.dart` にテスト2件を追加(合計4件)。`main.dart` は無変更。

- **AC2 文言検証** `Tapping logs "Button pressed"`: `debugPrint` を差し替えてログ捕捉 → `Button pressed` を検証。レビュー提案の `addTearDown` 復元版はフレームワークの不変条件チェックで落ちるため、`try/finally` でテスト本体内に同期復元する形へ調整(観点不変)。
- **AC3 回帰** `No overflow on a narrow surface`: 200x400 の狭い画面で例外が出ないことを検証。

再検証: `flutter analyze` = No issues found / `flutter test` = 4件全通過 / `dart format` 済み。
