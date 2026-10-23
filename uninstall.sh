#!/usr/bin/env bash
set -euo pipefail

# スクリプトの位置からDOTFILES_DIRを解決
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

# 削除対象のシンボリックリンク
SYMLINKS=(
    "$HOME/.zshrc"
    "$HOME/.tmux.conf"
    "$HOME/.gitconfig"
    "$HOME/.gitignore_global"
    "$HOME/.config/starship.toml"
    "$HOME/.config/nvim"
    "$HOME/.claude/settings.json"
    "$HOME/.claude/CLAUDE.md"
    "$HOME/.claude/hooks/markdownlint.sh"
    "$HOME/.markdownlint-cli2.jsonc"
    "$HOME/.config/ccstatusline/settings.json"
    "$HOME/.config/ghostty/config"
)

# OS ごとに配置先が異なるもの
if [[ "$OS" == "Darwin" ]]; then
    SYMLINKS+=(
        "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
        "$HOME/Library/Application Support/Code/User/settings.json"
    )
else
    SYMLINKS+=("$HOME/.config/Code/User/settings.json")
fi

# シンボリックリンクを削除する関数
remove_symlink() {
    local target="$1"

    if [[ -L "$target" ]]; then
        local link_target=$(readlink "$target")
        # dotfilesディレクトリへのリンクかどうか確認
        if [[ "$link_target" == "$DOTFILES_DIR"* ]]; then
            rm "$target"
            echo "✓ $target を削除しました。"
        else
            echo "⚠️  $target は dotfiles 以外を指しています。スキップします。"
        fi
    elif [[ -e "$target" ]]; then
        echo "⚠️  $target はシンボリックリンクではありません。スキップします。"
    else
        echo "- $target は存在しません。"
    fi
}

# バックアップから復元する関数
restore_backup() {
    local backup_dirs=($(ls -d "$HOME"/.dotfiles_backup_* 2>/dev/null || true))

    if [[ ${#backup_dirs[@]} -eq 0 ]]; then
        echo ""
        echo "復元可能なバックアップはありません。"
        return
    fi

    echo ""
    echo "📦 利用可能なバックアップ:"
    for i in "${!backup_dirs[@]}"; do
        echo "   [$i] ${backup_dirs[$i]}"
    done
    echo ""

    read -p "復元するバックアップの番号を選択してください (Enter でスキップ): " -r

    if [[ -z "$REPLY" ]]; then
        echo "復元をスキップしました。"
        return
    fi

    if [[ "$REPLY" =~ ^[0-9]+$ ]] && [[ "$REPLY" -lt ${#backup_dirs[@]} ]]; then
        local selected_backup="${backup_dirs[$REPLY]}"
        echo ""
        echo "📦 $selected_backup から復元します..."

        local manifest="$selected_backup/.manifest"
        if [[ -f "$manifest" ]]; then
            # 構造化バックアップ: manifest に記録されたパスをそのまま復元
            while IFS= read -r rel; do
                [[ -z "$rel" ]] && continue
                local src="$selected_backup/$rel"
                local dest="$HOME/$rel"

                if [[ ! -e "$src" ]]; then
                    echo "⚠️  バックアップに $rel が見つかりません。スキップします。"
                    continue
                fi

                if [[ -e "$dest" ]]; then
                    echo "⚠️  $dest は既に存在します。スキップします。"
                    continue
                fi

                mkdir -p "$(dirname "$dest")"

                if [[ -d "$src" ]]; then
                    cp -R "$src" "$dest"
                    echo "✓ $rel を $dest に復元しました。"
                elif [[ -f "$src" ]]; then
                    cp "$src" "$dest"
                    echo "✓ $rel を $dest に復元しました。"
                else
                    echo "⚠️  $rel は未対応の形式です。スキップします。"
                fi
            done < "$manifest"
        else
            # 旧形式バックアップ（basename保存）への互換復元
            for item in "$selected_backup"/*; do
                if [[ ! -e "$item" ]]; then
                    continue
                fi

                local name
                name="$(basename "$item")"

                local dest="$HOME/$name"

                # .config 配下に復元するもの
                if [[ "$name" == "starship.toml" ]]; then
                    mkdir -p "$HOME/.config"
                    dest="$HOME/.config/starship.toml"
                elif [[ "$name" == "nvim" ]]; then
                    mkdir -p "$HOME/.config"
                    dest="$HOME/.config/nvim"
                fi

                if [[ -e "$dest" ]]; then
                    echo "⚠️  $dest は既に存在します。スキップします。"
                    continue
                fi

                if [[ -d "$item" ]]; then
                    cp -R "$item" "$dest"
                    echo "✓ $name を $dest に復元しました。"
                elif [[ -f "$item" ]]; then
                    cp "$item" "$dest"
                    echo "✓ $name を $dest に復元しました。"
                else
                    echo "⚠️  $name は未対応の形式です。スキップします。"
                fi
            done
        fi
    else
        echo "無効な選択です。復元をスキップしました。"
    fi
}

echo "🗑️  dotfiles のアンインストールを開始します..."
echo "   DOTFILES_DIR: $DOTFILES_DIR"
echo ""

# シンボリックリンクを削除
for symlink in "${SYMLINKS[@]}"; do
    remove_symlink "$symlink"
done

# バックアップからの復元を提案
restore_backup

echo ""
echo "✅ dotfiles のアンインストールが完了しました。"
