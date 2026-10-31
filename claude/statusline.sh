#!/usr/bin/env bash
# Claude Code のステータスラインを ccstatusline / claude-hud から選んで実行する。
#
# settings.json の statusLine はこのスクリプトに固定し、どちらを使うかは
# ~/.claude/statusline-choice（マシンごとのローカルな選択、リポジトリ管理外）で決める。
# 切り替えても settings.json は変わらない。
#
#   statusline.sh              ステータスラインとして実行（Claude Code が呼ぶ。標準入力に JSON）
#   statusline.sh status       現在の選択を表示
#   statusline.sh ccstatusline ccstatusline に切り替える
#   statusline.sh hud          claude-hud に切り替える
set -u

CHOICE_FILE="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/statusline-choice"
HUD_LAUNCHER="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/claude-hud/statusline.mjs"
CCSTATUSLINE_CMD="ccstatusline@2.2.23"

current() {
    local choice=""
    [[ -f "$CHOICE_FILE" ]] && choice="$(<"$CHOICE_FILE")"
    case "$choice" in
        hud|ccstatusline) echo "$choice" ;;
        *) echo "ccstatusline" ;;
    esac
}

# bun を優先し、無ければ node を使う
find_runtime() {
    command -v bun 2>/dev/null || { [[ -x "$HOME/.bun/bin/bun" ]] && echo "$HOME/.bun/bin/bun"; } || command -v node 2>/dev/null
}

case "${1:-}" in
    status)
        echo "現在: $(current)"
        ;;
    ccstatusline|hud)
        mkdir -p "$(dirname "$CHOICE_FILE")"
        echo "$1" > "$CHOICE_FILE"
        echo "✓ $1 に切り替えました。次の更新から反映されます。"
        if [[ "$1" == "hud" && ! -f "$HUD_LAUNCHER" ]]; then
            echo "⚠️  claude-hud が未セットアップです。/plugin install claude-hud と /claude-hud:setup を実行してください。"
            echo "   （未セットアップの間は ccstatusline で表示します）"
        fi
        ;;
    "")
        if [[ "$(current)" == "hud" && -f "$HUD_LAUNCHER" ]]; then
            runtime="$(find_runtime)"
            if [[ -n "$runtime" ]]; then
                if [[ "$runtime" == *bun ]]; then
                    exec "$runtime" --env-file /dev/null "$HUD_LAUNCHER"
                fi
                exec "$runtime" "$HUD_LAUNCHER"
            fi
        fi
        # 既定、または claude-hud が使えないときのフォールバック
        exec bunx -y "$CCSTATUSLINE_CMD"
        ;;
    *)
        echo "使い方: statusline.sh [status|ccstatusline|hud]" >&2
        exit 1
        ;;
esac
