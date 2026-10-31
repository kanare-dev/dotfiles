#!/usr/bin/env bash
set -euo pipefail

# スクリプトの位置からDOTFILES_DIRを解決
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# OS 判定（macOS 専用の配置先を切り替える）
OS="$(uname -s)"

# バックアップのmanifest（元のパスを復元するため）
MANIFEST_FILE="$BACKUP_DIR/.manifest"

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
        echo "  まとめて: brew bundle --file=$DOTFILES_DIR/Brewfile  (Homebrew / Linuxbrew)"
        echo "  starship: curl -sS https://starship.rs/install.sh | sh"
        if [[ "$OS" == "Darwin" ]]; then
            echo "  fzf: brew install fzf"
        else
            echo "  fzf: sudo apt install fzf  (または git clone https://github.com/junegunn/fzf)"
        fi
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
        # $HOME 配下の相対パスを保持してバックアップする（構造化バックアップ）
        local rel
        if [[ "$target" == "$HOME/"* ]]; then
            rel="${target#"$HOME/"}"
        else
            # 想定外の場所は衝突回避のためフラットに退避
            rel="$(basename "$target")"
        fi
        mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
        mv "$target" "$BACKUP_DIR/$rel"
        echo "$rel" >> "$MANIFEST_FILE"
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

# tmux
create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

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

# Claude Code
# 注意: ~/.claude/ には会話履歴やキャッシュなど個人的・巨大なデータも
# 混在しているため、ディレクトリ全体ではなく設定ファイル単位でリンクする
mkdir -p "$HOME/.claude"
create_symlink "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
create_symlink "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
mkdir -p "$HOME/.claude/hooks"
create_symlink "$DOTFILES_DIR/claude/hooks/markdownlint.sh" "$HOME/.claude/hooks/markdownlint.sh"

# markdownlint (Claude Code の markdownlint フックが参照するグローバル設定)
create_symlink "$DOTFILES_DIR/markdownlint/.markdownlint-cli2.jsonc" "$HOME/.markdownlint-cli2.jsonc"

# ccstatusline
mkdir -p "$HOME/.config/ccstatusline"
create_symlink "$DOTFILES_DIR/claude/ccstatusline/settings.json" "$HOME/.config/ccstatusline/settings.json"

# Ghostty
# macOS では Application Support 配下が優先されるが、XDG (~/.config/ghostty) も
# フォールバックとして読まれるため両方にリンクしておく（Linux は XDG のみ）
if [[ "$OS" == "Darwin" ]]; then
    mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
    create_symlink "$DOTFILES_DIR/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
fi

mkdir -p "$HOME/.config/ghostty"
create_symlink "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"

# fastfetch
mkdir -p "$HOME/.config/fastfetch"
create_symlink "$DOTFILES_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"

# VSCode
if [[ "$OS" == "Darwin" ]]; then
    VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
else
    VSCODE_USER_DIR="$HOME/.config/Code/User"
fi
mkdir -p "$VSCODE_USER_DIR"
create_symlink "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"

if [[ -d "$BACKUP_DIR" ]]; then
    echo ""
    echo "📦 バックアップは $BACKUP_DIR に保存されました。"
fi

echo ""
echo "✅ dotfiles のインストールが完了しました。"
