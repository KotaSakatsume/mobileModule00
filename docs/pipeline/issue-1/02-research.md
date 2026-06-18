# ex00 調査パック (02-research)

> Issue: #1
> Stage: 2/5 Investigator
> 事実はコマンド出力または SDK ソース(ファイル:行)で裏付け。

## 1. 環境確認の事実
**結論: Flutter SDK は既にインストール済み。01-design が最大リスクとした「SDK 未セットアップ」は外れ。環境構築タスクの切り出しは不要。**

| 項目 | 値 |
|---|---|
| `flutter --version` | `Flutter 3.35.5 • channel [user-branch] • unknown source` / `Dart 3.9.2` / EXIT:0 |
| `dart --version` | `Dart SDK version: 3.9.2 (stable) ... on "macos_x64"` |
| `which flutter` | `/usr/local/bin/flutter` |
| SDK ルート | `/usr/local/share/flutter` |
| アーキ | x86_64 (Intel mac) / Darwin 21.6.0 |
| `which brew` | `/usr/local/bin/brew` |

- channel `[user-branch]` / `unknown source` 表示 → tarball/手動配置時の表示。動作に支障なし。ただし `flutter upgrade`/`flutter channel` はチャンネル前提で失敗しうる(リスク3)。

## 2. flutter create とプロジェクト名規約
**結論: `ex00` は valid な Dart package name。リネーム不要。**
- バリデーション本体 `isValidPackageName` (`create_base.dart:717-720`)、正規表現 `[a-z_][a-z0-9_]*` (`:637`)。`ex00` は先頭 `e` で全長一致、予約語にも非該当 → valid。
- 生成先ディレクトリ名がそのまま package name になるため `--project-name` 明示不要。
- `--empty` は使わない(01-design の「生成物のまま main.dart のみ差し替え」と整合)。

## 3. lint の事実
- 生成 `analysis_options.yaml.tmpl` は `include: package:flutter_lints/flutter.yaml`。`# avoid_print: false` の無効化コメント行が存在 = デフォルト有効の証拠。
- `flutter_lints-5.0.0/lib/flutter.yaml` で `avoid_print` を明示有効化 → `print('Button pressed')` は analyze 警告になる。**01-design の debugPrint 採用は事実として正しい。**
- **重要な事実訂正**: `debugPrint` は **release ビルドでも出力される**(`print.dart:34-37` "logs to console even in release mode"、内部で `print` を呼ぶ `:102`)。「debugPrint だからリリースで消える」は誤り。消したいなら `kDebugMode` ガードが必要。
- `avoid_print` は top-level `print` の直接呼び出しのみ対象。`debugPrint` は対象外 → analyze をパスする。

## 4. 既存リポジトリ状態
- ルート: `.claude/ docs/ README.md .git/`。`docs/` と `.claude/` は untracked。
- `mobileModule00/` ディレクトリは**存在しない** → 衝突なし、新規作成可。
- `flutter create` は `ex00/.gitignore`(build/, .dart_tool/ 無視)を生成する。

## 5. Implementer への具体的アクション(SDK あり = 分岐A を実行)
1. `mobileModule00/` を用意し、その中で `flutter create ex00` を実行(`--empty` 無し)。
2. `mobileModule00/ex00/lib/main.dart` のみを 01-design 通りに差し替え(MaterialApp → Scaffold → Center → Column(center) に Text + ElevatedButton、`onPressed: () => debugPrint('Button pressed')`、StatefulWidget)。
3. 他生成物(pubspec.yaml / analysis_options.yaml / android・ios 等)は触らない。`analysis_options.yaml` の lint include を消さない。
4. 合否確認: `cd mobileModule00/ex00 && flutter analyze` → **No issues found** を確認。
5. (任意) `dart format lib/main.dart`。

## 6. 落とし穴・注意点
- **リスク1**: 「debugPrint はリリースで消える」という思い込み。analyze 上は無害なのでデフォルトはガード無しで可。課題意図を勝手に仮定しない。
- **リスク2**: うっかり `print(...)` → analyze warning。`analysis_options.yaml` で `avoid_print: false` にして黙らせる逃げはアンチパターン。main.dart 側を `debugPrint` にして解決するのが正道。
- **リスク3**: channel が `[user-branch]`。`flutter upgrade`/`channel` を**実行しない**。タスクは「生成 + main.dart 編集 + analyze」に限定し SDK を触らない。
- **補足(テスト破壊)**: `flutter create` はデフォルトで `test/widget_test.dart`(カウンターアプリ前提)を生成。main.dart を差し替えると `flutter test` が**失敗する**。01-design の合否基準は analyze + レビューで test 必須ではないので影響なし。ただし将来 test を回すなら `test/widget_test.dart` を新 UI に合わせ修正/削除が必要 → **Implementer は新 UI に合わせて widget_test.dart を更新するか削除しておくのが安全**。

## 参照ファイル
- `/usr/local/share/flutter/packages/flutter_tools/lib/src/commands/create_base.dart` (:637,:641,:717-753)
- `.../templates/app/analysis_options.yaml.tmpl`, `.../pubspec.yaml.tmpl` (`flutter_lints: ^5.0.0`)
- `/Users/kotasakatsume/.pub-cache/hosted/pub.dev/flutter_lints-5.0.0/lib/flutter.yaml`
- `/usr/local/share/flutter/packages/flutter/lib/src/foundation/print.dart` (:34-49,:70-103)
