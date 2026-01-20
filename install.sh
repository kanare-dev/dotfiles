#!/usr/bin/env bash
set -euo pipefail

# スクリプトの位置からDOTFILES_DIRを解決
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# 必要なツールをチェックする関数
check_prerequisites() {
    local missing_tools=()

    if ! command -v starship &> /dev/null; then
        missing_tools+=("starship")
    fi

    if ! command -v fzf &> /dev/null && [[ ! -f "$HOME/.fzf.zsh" ]]; then
        missing_tools+=("fzf")
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo "⚠️  以下のツールがインストールされていません:"
        for tool in "${missing_tools[@]}"; do
            echo "   - $tool"
        done
        echo ""
        echo "インストール方法:"
        echo "  starship: curl -sS https://starship.rs/install.sh | sh"
        echo "  fzf: brew install fzf"
        echo ""
        read -p "続行しますか? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "インストールを中止しました。"
            exit 1
        fi
    fi
}

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
echo "   DOTFILES_DIR: $DOTFILES_DIR"
echo ""

# 前提条件をチェック
check_prerequisites

# zsh
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# git
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"

# starship
if ! mkdir -p "$HOME/.config"; then
    echo "❌ エラー: $HOME/.config ディレクトリを作成できませんでした。"
    exit 1
fi
create_symlink "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# nvim
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

if [[ -d "$BACKUP_DIR" ]]; then
    echo ""
    echo "📦 バックアップは $BACKUP_DIR に保存されました。"
fi

echo ""
echo "✅ dotfiles のインストールが完了しました。"
