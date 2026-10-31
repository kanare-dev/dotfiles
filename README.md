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
- **claude**: Claude Code のユーザー設定 (`~/.claude/settings.json`)、グローバル指示 (`~/.claude/CLAUDE.md`)、Markdown 編集後に markdownlint を走らせるフック (`~/.claude/hooks/markdownlint.sh`)
- **markdownlint**: markdownlint-cli2 のグローバル設定 (`~/.markdownlint-cli2.jsonc`、MD013 を無効化)
- **ccstatusline**: Claude Code ステータスライン設定 (`~/.config/ccstatusline/` 配下の `settings.json` と、バー描画用スクリプト。詳細は [claude/README.md](claude/README.md))
- **ghostty**: Ghostty ターミナル設定 (macOS: `~/Library/Application Support/com.mitchellh.ghostty/config`、共通: `~/.config/ghostty/config`)
- **fastfetch**: fastfetch の表示設定 (`~/.config/fastfetch/config.jsonc`、Nerd Font アイコン付きの項目名)
- **vscode**: VSCode のユーザー設定 (macOS: `~/Library/Application Support/Code/User/settings.json`、Linux: `~/.config/Code/User/settings.json`)
- **Brewfile / Brewfile.extra**: 入れているツールの台帳（リンクはせず `brew bundle` で使う）。`Brewfile` は全マシン共通の最小セット、`Brewfile.extra` は重いツールや macOS 専用の GUI アプリ（cask）

## git のローカル分離（推奨）

このリポジトリの `git/.gitconfig` は `~/.gitconfig.local` を読み込むようになっています。
個人情報（`user.name` / `user.email`）やマシン固有設定は `~/.gitconfig.local` に置いてください。

例:

```bash
cp ./git/.gitconfig.local.example ~/.gitconfig.local
```

## 前提条件

ツール一式は Homebrew / Linuxbrew 用の Brewfile にまとめています。共通セットと追加セットの 2 つに分けています:

- `Brewfile`: 全マシン共通の最小セット（Linux VM でも入れる）
- `Brewfile.extra`: 重いもの（go / node / ansible など）、インフラ・ドキュメント系、macOS 専用の GUI アプリ。必要なマシンだけで流す

```bash
brew bundle --file=Brewfile            # 共通セット
brew bundle --file=Brewfile.extra      # 追加セット（手元の Mac など）
cat Brewfile Brewfile.extra | brew bundle cleanup --file=-   # どちらにも無いものを確認（--force で削除）
```

### Linux VM（Debian / Ubuntu）

macOS 以外でも同じ手順で使えます。Linuxbrew を入れてから共通の `Brewfile` を流すだけです（`Brewfile.extra` は不要）:

```bash
sudo apt install -y build-essential curl git zsh   # Linuxbrew のビルド依存と zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone https://github.com/kanare-dev/dotfiles.git ~/dotfiles && cd ~/dotfiles
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"   # このシェルだけ brew を有効化
brew bundle --file=Brewfile
./install.sh
chsh -s "$(command -v zsh)"
```

- `.zshrc` が `/home/linuxbrew/.linuxbrew` と `~/.linuxbrew` を自動検出するため、`~/.zprofile` の編集は不要
- ghostty / vscode / fastfetch の設定も Linux 用のパス（`~/.config/...`）にリンクされる。ヘッドレスな VM では使われないだけで無害
- `git/.gitconfig.local` を VM 側にも用意する（上記「git のローカル分離」参照）

最低限、以下はインストールスクリプトがチェックします:

- **starship**: `curl -sS https://starship.rs/install.sh | sh`
- **fzf**: `brew install fzf`（Linux は `sudo apt install fzf`）

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
│   ├── CLAUDE.md
│   ├── README.md
│   ├── hooks/
│   │   └── markdownlint.sh
│   └── ccstatusline/
│       ├── settings.json
│       ├── context-bar.sh
│       └── usage-line.sh
├── markdownlint/
│   └── .markdownlint-cli2.jsonc
├── ghostty/
│   └── config
├── fastfetch/
│   └── config.jsonc
├── vscode/
│   └── settings.json
├── Brewfile
├── Brewfile.extra
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
