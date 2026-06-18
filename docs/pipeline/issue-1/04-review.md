# ex00 レビュー (04-review)

> Issue: #1
> Stage: 4/5 Reviewer

## 総評
設計の AC1〜AC5・全制約を満たし、analyze/test もクリーン。**must は 0 件で、段階5へ進んでよい(approve)。**

## 設計準拠チェック
| 項目 | 判定 | 根拠 |
|---|---|---|
| AC1: Center > Column(center) に Text と Button | ○ | `Center > Column(mainAxisAlignment.center)` に Text と ElevatedButton |
| AC2: 押下で `Button pressed` を debug 出力(UI非表示・完全一致) | ○ | `onPressed: () => debugPrint('Button pressed')`。文言完全一致、UI非表示 |
| AC3: 回転・異サイズで非破綻(固定座標なし) | ○ | 固定座標なし。Center/Column のみ。短文のため実害なし(should 参照) |
| AC4: analyze クリーン(print 不使用) | ○ | `debugPrint` 使用、`print` 不使用。No issues found |
| AC5: クラッシュしない | ○ | テストで takeException is null を確認 |
| 制約: import は material のみ | ○ | `package:flutter/material.dart` のみ |
| 制約: 追加依存なし | ○ | pubspec 変更なし |
| 制約: StatefulWidget 採用 | ○ | `MyApp extends StatefulWidget` |
| 制約: lint 無効化なし | ○ | analysis_options 変更なし |
| Non-goal 不混入 | ○ | 単一 Scaffold のみ |

スコープ逸脱なし。設計との差分なし。

## 指摘リスト

### must
なし。

### should
- **[should] AC3 のテスト裏付けが無い** — 異サイズでの非破綻が実装上は満たされるがテスト未保証。narrow surface での例外なしを1ケース追加推奨:
  ```dart
  testWidgets('No overflow on a narrow surface', (tester) async {
    tester.view.physicalSize = const Size(200, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp());
    expect(tester.takeException(), isNull);
  });
  ```
- **[should] AC2 の出力内容が未検証** — 2つ目のテストは「例外が出ない」のみで `Button pressed` 文言を検証していない。AC2 の核心が回帰検知されない。`debugPrint` 差し替えで捕捉推奨:
  ```dart
  testWidgets('Tapping logs "Button pressed"', (tester) async {
    final logs = <String>[];
    final original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) logs.add(message);
    };
    addTearDown(() => debugPrint = original);
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(logs, contains('Button pressed'));
  });
  ```

### nit
- StatefulWidget だが State にミュータブルフィールドなし → 設計が将来 ex01 用に明示採用。制約準拠で問題なし(記録のみ)。
- `MyApp`/`_MyAppState` は flutter create 既定名のまま。ex00 では許容。`BasicDisplayApp` 等にすると意図が明確。
- `MaterialApp` に `debugShowCheckedModeBanner: false` 無し。要件外。

## セキュリティ
該当なし。外部入力・ネットワーク・機密情報・依存追加いずれも無く、ローカル UI 単一画面で攻撃面なし。

## 結論
**段階5へ進んでよい(approve)。** must は 0 件。
should 2件(AC2 文言検証、AC3 回帰テスト)は合否をブロックしないが、両 AC が「実装は満たすがテストが守っていない」状態のため取り込み推奨(特に AC2 文言検証を優先)。

---

## 再レビュー(差し戻し後 / should 2件 取り込み)
should 2件をユーザー判断で取り込み、段階3へ差し戻して修正済み。

- ✅ **[should解消] AC2 文言検証** — `Tapping logs "Button pressed"` テスト追加。`debugPrint` を捕捉し `expect(logs, contains('Button pressed'))` で検証。
  - 注: レビュー提案の `addTearDown(() => debugPrint = original)` 版は、`flutter_test` が「foundation の debug 変数(`debugPrint` 含む)はテア ダウンコールバックより**前に**復元済みであること」を不変条件として検証するため `The value of a foundation debug variable was changed by the test.` で失敗する。Implementer が `try/finally` でテスト本体内に同期復元する形へ調整(観点・スコープ不変)。妥当と判断。
- ✅ **[should解消] AC3 回帰テスト** — `No overflow on a narrow surface`(200x400)テスト追加。提案コードのまま。
- `main.dart` は無変更(挙動・UI 不変)。変更は `test/widget_test.dart` のみ。

**再検証結果(実コマンド出力):**
- `flutter analyze` → `No issues found! (ran in 82.8s)`
- `flutter test` → 4テスト全通過(`+4: All tests passed!`)
- `dart format` → 整形済み

**最終結論: approve。must 0 件、should 0 件(全解消)。段階5(Integrator)へ進む。**
