# Dotfiles

個人用の設定ファイルを管理するリポジトリです。

## ターミナルの外見

![ターミナルの外見-1](assets/terminal-1.png)
![ターミナルの外見-2](assets/terminal-2.png)

## 含まれる設定

- **zsh**: `.zshrc` 設定ファイル
- **tmux**: `.tmux.conf` 設定ファイル
- **git**: `.gitconfig` と `.gitignore_global` 設定ファイル
- **starship**: プロンプトカスタマイズ設定 (`starship.toml`)
- **nvim**: Neovim 設定 (`~/.config/nvim`)
- **claude**: Claude Code のユーザー設定 (`~/.claude/settings.json`) とグローバル指示 (`~/.claude/CLAUDE.md`)
- **ccstatusline**: Claude Code ステータスライン設定 (`~/.config/ccstatusline/settings.json`)
- **ghostty**: Ghostty ターミナル設定 (`~/Library/Application Support/com.mitchellh.ghostty/config`)
- **vscode**: VSCode のユーザー設定 (`~/Library/Application Support/Code/User/settings.json`)

## git のローカル分離（推奨）

このリポジトリの `git/.gitconfig` は `~/.gitconfig.local` を読み込むようになっています。
個人情報（`user.name` / `user.email`）やマシン固有設定は `~/.gitconfig.local` に置いてください。

例:

```bash
cp ./git/.gitconfig.local.example ~/.gitconfig.local
```

## 前提条件

以下のツールのインストールを推奨します（インストールスクリプトがチェックします）:

- **starship**: `curl -sS https://starship.rs/install.sh | sh`
- **fzf**: `brew install fzf`

## インストール方法

```bash
./install.sh
```

このスクリプトは、各設定ファイルをホームディレクトリにシンボリックリンクとして配置します。

## アンインストール方法

```bash
./uninstall.sh
```

シンボリックリンクを削除し、バックアップからの復元を選択できます。

## 構成

```plaintext
dotfiles/
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
├── nvim/
│   ├── init.lua
│   └── lua/
│       └── core.lua
├── zsh/
│   └── .zshrc
├── tmux/
│   └── .tmux.conf
├── starship/
│   └── starship.toml
├── claude/
│   ├── settings.json
│   └── CLAUDE.md
├── ccstatusline/
│   └── settings.json
├── ghostty/
│   └── config
├── vscode/
│   └── settings.json
├── install.sh
├── uninstall.sh
└── README.md
```

## Claude Code の設定について

`~/.claude/` には設定以外に会話履歴・セッション・キャッシュなど個人的/巨大なデータが
大量に混在しているため、ディレクトリ全体ではなく `settings.json` のみをシンボリック
リンクで管理しています。以下は意図的に対象外です。

- `history.jsonl` / `projects/` / `sessions/` / `shell-snapshots/` などの会話履歴・実行時データ
- `plugins/` / `skills/skill-creator` など、marketplace からインストールされる/同梱される生成物
- `~/.claude.json`（MCPサーバー設定やプロジェクト固有情報を含み、マシン間で共有すべきでない）

## VSCode の設定について

`settings.json` のみを管理対象としています。Settings Sync と併用する場合は、
衝突を避けるため Settings Sync の「設定」項目をオフにしてください。
この切り替えは `settings.json` では指定できないため、コマンドパレットの
`Settings Sync: Configure...` から手動で行います。

## 注意事項

- `install.sh` は既存のファイルを自動的にバックアップします（`~/.dotfiles_backup_YYYYMMDD_HHMMSS/` に保存されます）
- バックアップは **元のパス構造を保持**して保存され、復元用に `~/.dotfiles_backup_.../.manifest` が作成されます
- 既に正しいシンボリックリンクが設定されている場合は、スキップされます
- 既存のファイルや間違ったシンボリックリンクがある場合は、バックアップを取ってから新しいリンクを作成します
