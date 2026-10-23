---
description: 外部から追記された zsh / vscode / claude の設定を既存の構成に整理する
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(python3:*), Bash(zsh -n:*), Read, Edit
---

## Context

- 未コミットの変更: !`git status --short -- zsh vscode claude/settings.json`
- 差分: !`git diff -- zsh vscode claude/settings.json`

## Your task

VSCode アプリ・シェルのインストーラ・Claude Code 本体（`/plugin` や `/config` など）が追記・並べ替えした設定を、既存の構成に沿って整理する。対象は上の差分に出ている `zsh/`・`vscode/`・`claude/settings.json` だけ。差分が無ければその旨を伝えて終わる。

### 共通

- 追記された設定を、意味の合う既存セクションへ移す。合うセクションが無ければ、既存の形式で新設する。
- 重複や、既存の設定と矛盾するものは、勝手に消さず報告する。
- 設定の値や意味は変えない。移動・整形・コメント追加だけにする。
- 整理後の差分を見せ、了承を得るまでコミットしない。

### vscode/settings.json

- JSONC。`// ====` 区切りの見出しと、設定ごとの日本語コメントに合わせる。
- 見出しは分野ごと（Editor / Explorer / Files / Git / Extensions など）。キーは各セクション内でアルファベット順にそろえる。
- 言語別設定（`"[markdown]"` など）は専用のセクションにまとめる。
- 編集後に構文を確認する（コメントと末尾カンマは許容されるため、厳密な JSON パーサーは使わない）。括弧の対応を目視で確認する。

### zsh/.zshrc

- `# ====` 区切りのセクションごとに「思想:」コメントで意図を書く形式に合わせる。
- 追記が `nvm` / `conda` / `pyenv` などのインストーラによるものなら、該当ツールのセクションに「思想:」付きで移す。
- 編集後に `zsh -n zsh/.zshrc` で構文を確認する。
- PATH は先頭のセクション、プロンプトは最後、という既存の読み込み順を崩さない。

### claude/settings.json

- 厳密な JSON（コメント・末尾カンマは不可）。稼働中の Claude Code 設定そのものなので、壊さない。
- Claude Code 本体が書き換えるとキー順が崩れるため、次の順に並べ直す: 基本設定（`model` など）→ `statusLine` → `hooks` → `permissions` → `enabledPlugins` → `extraKnownMarketplaces` → UI・通知系（`tui`, `agentPushNotifEnabled` など）。上に無いキーは意味の近い位置へ置く。
- `enabledPlugins` と `extraKnownMarketplaces` は対応を確認する（マーケットプレイスを追加したプラグインが有効化されているか、逆に未登録のマーケットプレイスを参照していないか）。ずれは報告する。
- 編集後に `python3 -c "import json; json.load(open('claude/settings.json'))"` で構文を確認する。

### コミット

了承後、設定のスコープ単位（`vscode`, `zsh`, `claude`）で、`type(scope): summary` 形式でコミットする。`git add` はファイル名を明示する。
