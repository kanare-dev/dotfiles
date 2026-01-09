#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# シンボリックリンクを作成する関数
# 既存ファイルがある場合はバックアップを取る
create_symlink() {
    local source="$1"
    local target="$2"
    
    # ソースファイルの存在確認
    if [[ ! -e "$source" ]]; then
        echo "⚠️  警告: $source が存在しません。スキップします。"
        return 1
    fi
    
    # ターゲットが既に正しいシンボリックリンクの場合
    if [[ -L "$target" ]]; then
        local current_link=$(readlink "$target")
        if [[ "$current_link" == "$source" ]]; then
            echo "✓ $target は既に正しく設定されています。"
            return 0
        else
            echo "⚠️  警告: $target は別のリンクを指しています ($current_link)"
        fi
    fi
    
    # ターゲットが通常のファイルまたはディレクトリの場合
    if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
        echo "📦 既存の $target をバックアップします..."
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/$(basename "$target")"
    fi
    
    # シンボリックリンクを作成
    ln -sf "$source" "$target"
    echo "✓ $target を作成しました。"
}

echo "🚀 dotfiles のインストールを開始します..."

# zsh
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# git
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"

# starship
mkdir -p "$HOME/.config"
create_symlink "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

if [[ -d "$BACKUP_DIR" ]]; then
    echo ""
    echo "📦 バックアップは $BACKUP_DIR に保存されました。"
fi

echo ""
echo "✅ dotfiles のインストールが完了しました。"
