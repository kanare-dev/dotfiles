# Claude Code ステータスライン

Claude Code の入力欄の下に出るステータスラインは **ccstatusline** を使っている。見た目の設計と、運用メモをまとめる。

> このディレクトリの `CLAUDE.md` は `~/.claude/CLAUDE.md` にリンクされるグローバル指示で、この README とは別物。

## 仕組み

`settings.json` の `statusLine` が ccstatusline を直接起動する。バージョンはここで固定している。

```json
"statusLine": {
  "type": "command",
  "command": "bunx -y ccstatusline@2.2.33",
  "padding": 0,
  "refreshInterval": 10
}
```

- Claude Code は標準入力にセッション情報の JSON（モデル、コンテキスト、`rate_limits` など）を渡す。
- `refreshInterval: 10` で、イベントが無くても 10 秒ごとに再描画する（リセットまでの時間などを更新するため）。
- バージョンを固定しているのは、`@latest` だと更新のたびに再取得が走って遅くなり、設定の仕様変更にも気づけないため。

## ファイルの配置

| リポジトリ | ホーム側 | 内容 |
| --- | --- | --- |
| `claude/ccstatusline/settings.json` | `~/.config/ccstatusline/settings.json` | 表示設定 |
| `claude/ccstatusline/context-bar.sh` | `~/.config/ccstatusline/context-bar.sh` | 使用率のバーを出力するスクリプト |
| `claude/ccstatusline/usage-line.sh` | `~/.config/ccstatusline/usage-line.sh` | 2行目（使用量）を 1 本のテキストで出力するスクリプト |

すべてシンボリックリンクで、`./install.sh` で作成される。

## 見た目の設計

- **1行目**は Powerline 形式（丸い起点・`>` の区切り・丸い終端）。色は starship の暖色グラデーションと、参考画像に合わせた赤・橙・黄・緑・青・紫。背景色は `bgBlue` のような名前ではなく `hex:RRGGBB` で指定する（`colorLevel: 3`）。
- 各項目のアイコンは Nerd Font のグリフ。ディレクトリは `character`、モデルなどは `metadata.label` で指定する。
- **2行目**は背景なしのグレーの文字（`#A0A0A0`）で、区切りは縦線 `│`。Powerline の起点・区切り・終端は行ごとに切り替えられないため、行全体を `usage-line.sh` の出力 1 つ（`custom-command`）にしている。`powerline.startCaps` / `endCaps` の 2 番目を空にしているのは、2行目に丸いグリフを出さないため（インデックスが行ごとに進む）。
- **バーは標準の `context-bar` ではなく、自作の `context-bar.sh` を `custom-command` で呼んでいる。** 標準のバーは `█` と `░` が固定で、`░` が明るい背景に溶けて見づらいため。
  - 書式: `context-bar.sh <style> <width> <icon> <field>`。`settings.json` では `squares 10` を使う。
  - style: `blocks`, `braille`, `dots`, `squares`, `bars`, `line`, `diamonds`, `stars`, `smooth`。
  - icon: 先頭に付けるアイコンやラベル。空白を含むときは引用符で囲む。
  - field: `context`（既定。`context_window.used_percentage`）、`five_hour`（`rate_limits.five_hour.used_percentage`）、`seven_day`（`rate_limits.seven_day.used_percentage`）。
  - 値が取得できないときは何も出さない（ピルや行ごと非表示になる）。`jq` が無ければ `python3` で読む。
- `usage-line.sh` は `context-bar.sh` を同じディレクトリから呼び、5時間枠・週・リセットまでの時間を `│` でつなぐ。リセットは `rate_limits.five_hour.resets_at` から計算する。
- `commandPath` は `$HOME` を展開して実行される。スクリプトは `~/.config/ccstatusline/` にリンクされるので、`settings.json` からは `$HOME/.config/ccstatusline/…` で参照する。

## 設定を変えるとき

- `npx -y ccstatusline@<版>` か `bunx -y ccstatusline@<版>` で TUI を開いて編集すると、リンク先（リポジトリの `settings.json`）が直接更新される。
- TUI の「Install」は `settings.json` の `statusLine` を書き換えようとするので使わない。
- 新しい版は、初回実行時に設定ファイルの `version` を自動で移行して書き換えることがある（`3` → `4` など）。差分を確認してコミットする。

## バージョンを上げる

1. 最新版を確認する: `npm view ccstatusline version`
2. リリースノートで、設定の互換性やデフォルト値の変更を確認する: `gh release list -R sirmalloc/ccstatusline`
3. `claude/settings.json` の `statusLine.command` の `ccstatusline@<版>` を書き換える。
4. 一度実行して表示を確認し、`claude/ccstatusline/settings.json` の差分（`version` の移行など）をコミットに含める。

## トラブルシューティング

| 症状 | 確認すること |
| --- | --- |
| 何も表示されない | 信頼されていないワークスペースでは、Claude Code がステータスラインを実行しない場合がある。`bun` が PATH にあるかも確認する |
| 2行目の `5h` や `7d` が出ない | 標準入力に `rate_limits` が入っていない可能性がある（サブスクリプションのログインが必要）。`echo '{"rate_limits":{"five_hour":{"used_percentage":23}}}' \| ~/.config/ccstatusline/context-bar.sh squares 10 5h five_hour` で単体確認できる |
| 丸いグリフや矢印が豆腐になる | ターミナルのフォントが Nerd Font か確認する（Ghostty は `JetBrainsMono Nerd Font`） |
| 色が違って見える | `colorLevel: 3`（トゥルーカラー）に対応した端末か確認する |
