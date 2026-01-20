# Dotfiles

個人用の設定ファイルを管理するリポジトリです。

## 含まれる設定

- **zsh**: `.zshrc` 設定ファイル
- **git**: `.gitconfig` と `.gitignore_global` 設定ファイル
- **starship**: プロンプトカスタマイズ設定 (`starship.toml`)
- **nvim**: Neovim 設定 (`~/.config/nvim`)

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

```
dotfiles/
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
├── nvim/
│   └── init.lua
├── zsh/
│   └── .zshrc
├── starship/
│   └── starship.toml
├── install.sh
├── uninstall.sh
└── README.md
```

## 注意事項

- `install.sh` は既存のファイルを自動的にバックアップします（`~/.dotfiles_backup_YYYYMMDD_HHMMSS/` に保存されます）
- 既に正しいシンボリックリンクが設定されている場合は、スキップされます
- 既存のファイルや間違ったシンボリックリンクがある場合は、バックアップを取ってから新しいリンクを作成します
