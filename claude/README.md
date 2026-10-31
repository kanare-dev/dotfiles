# Claude Code ステータスライン

Claude Code の入力欄の下に出るステータスラインを、**ccstatusline** と **claude-hud** から選んで使うための仕組みと運用メモ。

> このディレクトリの `CLAUDE.md` は `~/.claude/CLAUDE.md` にリンクされるグローバル指示で、この README とは別物。

## 切り替え

```bash
~/.claude/statusline.sh status         # 現在の選択を表示
~/.claude/statusline.sh ccstatusline   # ccstatusline に切り替え
~/.claude/statusline.sh hud            # claude-hud に切り替え
```

切り替えは次のステータスライン更新から反映される。Claude Code の再起動は不要。

## 仕組み

```text
Claude Code
  └─ settings.json の statusLine: "bash ~/.claude/statusline.sh"   ← 固定
       └─ ~/.claude/statusline-choice を読む                        ← 切り替えるのはここだけ
            ├─ ccstatusline → bunx -y ccstatusline@<固定版>
            └─ hud          → ~/.claude/plugins/claude-hud/statusline.mjs
```

- `settings.json` の `statusLine` は常に `statusline.sh` を指す。切り替えても `settings.json` は変わらないので、リポジトリに差分が出ない。
- 選択は `~/.claude/statusline-choice`（`ccstatusline` または `hud`）に保存される。**マシンごとのローカルな値でリポジトリ管理外**。ファイルが無い、または値が不正なら `ccstatusline`。
- `hud` を選んでいても、claude-hud のランチャー（`statusline.mjs`）か実行環境（bun / node）が無ければ、ccstatusline にフォールバックする。
- Claude Code は標準入力にセッション情報の JSON を渡す。`statusline.sh` は `exec` で各ツールに引き継ぐので、そのまま渡る。

## ファイルの配置

| リポジトリ | ホーム側 | 方式 | 内容 |
| --- | --- | --- | --- |
| `claude/statusline.sh` | `~/.claude/statusline.sh` | リンク | 切り替えスクリプト |
| `claude/ccstatusline/settings.json` | `~/.config/ccstatusline/settings.json` | リンク | ccstatusline の表示設定 |
| `claude/ccstatusline/context-bar.sh` | `~/.config/ccstatusline/context-bar.sh` | リンク | 使用率のバーを出力するスクリプト |
| `claude/ccstatusline/usage-line.sh` | `~/.config/ccstatusline/usage-line.sh` | リンク | 2行目（使用量）を 1 本のテキストで出力するスクリプト |
| `claude/claude-hud/config.json` | `~/.claude/plugins/claude-hud/config.json` | **コピー** | claude-hud の表示設定 |

claude-hud は、設定ファイルがシンボリックリンクだと読み込みを拒否する（`O_NOFOLLOW`）。リンクにすると既定値で動いてしまうため、`install.sh` の `copy_file` でコピー配置している。

## 設定を変えるとき

### ccstatusline

- `npx -y ccstatusline@<版>` か `bunx -y ccstatusline@<版>` で TUI を開いて編集すると、リンク先（リポジトリの `settings.json`）が直接更新される。
- TUI の「Install」は `settings.json` の `statusLine` を書き換えようとするので使わない（`statusline.sh` 経由に固定しているため）。
- 新しい版は、初回実行時に設定ファイルの `version` を自動で移行して書き換えることがある（`3` → `4` など）。差分を確認してコミットする。

### claude-hud

- `/claude-hud:configure` か `claude/claude-hud/config.json` を編集する。
- **ホーム側はコピーなので、`/claude-hud:configure` で変えた内容はリポジトリに自動では戻らない。** 残したい内容は `claude/claude-hud/config.json` に手で反映する。
- リポジトリ側を編集したときは `./install.sh` でホーム側に反映する。内容が違えば、元のファイルを `~/.dotfiles_backup_*` に退避してから上書きする。
- `/claude-hud:setup` は `settings.json` の `statusLine` を上書きする。実行したら `git diff claude/settings.json` を確認し、`statusLine` を `bash ~/.claude/statusline.sh` に戻す。

### ccstatusline の見た目

- **1行目**は Powerline 形式（丸い起点・`>` の区切り・丸い終端）。色は starship の暖色グラデーションと、画像を参考にした赤・橙・黄・緑・青・紫を使う。背景色は `bgBlue` のような名前ではなく `hex:RRGGBB` で指定する（`colorLevel: 3`）。
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

## ccstatusline のバージョンを上げる

1. 最新版を確認する: `npm view ccstatusline version`
2. リリースノートで、設定の互換性やデフォルト値の変更を確認する: `gh release list -R sirmalloc/ccstatusline`
3. `claude/statusline.sh` の `CCSTATUSLINE_CMD="ccstatusline@<版>"` を書き換える。
4. 一度実行して表示を確認し、`claude/ccstatusline/settings.json` の差分（`version` の移行など）をコミットに含める。

版を固定しているのは、`@latest` だと更新のたびに再取得が走って遅くなり、設定の仕様変更に気づけないため。

## 新しいマシンでの準備

1. `./install.sh`（`statusline.sh` のリンクと、claude-hud の `config.json` のコピーが入る）
2. 既定の ccstatusline はそのまま動く（`bun` が必要）。
3. claude-hud を使う場合は、Claude Code 内で `/plugin marketplace add jarrodwatts/claude-hud`、`/plugin install claude-hud`、`/claude-hud:setup` を実行し、`statusLine` を戻してから `~/.claude/statusline.sh hud` を実行する。

## トラブルシューティング

| 症状 | 確認すること |
| --- | --- |
| 切り替えても見た目が変わらない | 次のメッセージ送信後に更新される。`statusline.sh status` で選択を確認する |
| `hud` にしたのに ccstatusline が出る | `~/.claude/plugins/claude-hud/statusline.mjs` の有無と、`bun` / `node` が PATH にあるかを確認する |
| claude-hud の設定が反映されない | ホーム側の `config.json` がシンボリックリンクになっていないか（`ls -l`）。リンクなら `./install.sh` でコピーに置き換える |
| `statusLine` が元に戻った | `/claude-hud:setup` が上書きした可能性がある。`settings.json` の `statusLine` を確認する |
| 何も表示されない | 信頼されていないワークスペースでは、Claude Code がステータスラインを実行しない場合がある |
