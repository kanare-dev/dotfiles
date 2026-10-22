# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

macOS 向けの個人用 dotfiles。ビルド・テスト・lint の仕組みはない。各設定ファイルを `install.sh` がホームディレクトリ配下へシンボリックリンクとして配置する。

```bash
./install.sh      # リンク作成（既存ファイルは ~/.dotfiles_backup_YYYYMMDD_HHMMSS/ に退避）
./uninstall.sh    # リンク削除 + バックアップからの復元を対話的に選択
bash -n install.sh uninstall.sh   # スクリプト変更後の構文チェック
```

`install.sh` は冪等で、正しいリンクが既にあればスキップする。starship / fzf が無いと続行確認を求める。

## アーキテクチャ

- リポジトリ内のファイルが実体で、ホーム側がリンク。**リポジトリ内の編集は即座に稼働中の設定へ反映される。** 特に `claude/settings.json`（`~/.claude/settings.json`）は壊れた JSON を書くと Claude Code 自体の設定が読めなくなる。編集後は `python3 -c "import json; json.load(open('claude/settings.json'))"` で確認する。
- `claude/CLAUDE.md` は **このファイルではなく**、`~/.claude/CLAUDE.md` にリンクされるグローバル指示（全プロジェクトに適用される）。リポジトリ作業用の指示はルートのこの `CLAUDE.md` に書く。
- `vscode/settings.json` は JSONC（コメント・末尾カンマ可）。Settings Sync の「設定」項目はオフにする前提（`settings.json` からは指定できない）。
- `~/.claude/` と `~/.claude.json` は履歴・キャッシュ・マシン固有情報を含むため、ディレクトリ全体ではなく `settings.json` と `CLAUDE.md` のみをリンクしている。同様の理由で、ディレクトリ丸ごとではなくファイル単位でリンクするのがこのリポジトリの方針（`nvim` のみ例外的にディレクトリ単位）。
- git は `git/.gitconfig` が `~/.gitconfig.local` を読み込む。`user.name` / `user.email` などマシン固有の値はそちらに置き、リポジトリには入れない（`.gitignore` で `*.local` / `*.secret` を除外済み）。

## 設定を追加・移動するとき

新しいツールの設定を管理対象にする場合は、次の3か所を揃えて更新する。

1. `install.sh`: `create_symlink "$DOTFILES_DIR/<src>" "<target>"`（親ディレクトリは事前に `mkdir -p`）
2. `uninstall.sh`: 冒頭の `SYMLINKS` 配列にターゲットを追加
3. `README.md`: 「含まれる設定」と「構成」のツリー

バックアップは `$HOME` からの相対パスを保持して保存され、`.manifest` に記録される。`uninstall.sh` の復元はこの manifest を前提にする（manifest が無い旧形式への互換コードもある）。

## 規約

- コメントや README は日本語。コミットメッセージは Conventional Commits（`type(scope): 要約`）で、スコープはツール名（`zsh`, `vscode`, `claude` など）。
- `zsh/.zshrc` は `# ====` 区切りのセクションごとに「思想:」コメントで意図を書くスタイル。追記時もこの形式に合わせる。
- `tmux` / `nvim` / `ghostty` には操作マニュアルとしての `README.md` がある。キーバインドや設定値を変えたら対応する README の表も更新する。
