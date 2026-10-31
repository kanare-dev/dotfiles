#!/usr/bin/env bash
# ccstatusline の custom-command ウィジェット用: 使用量の行を 1 本のテキストで出力する。
# 標準入力に Claude Code のセッション JSON を受け取る。
#
#   󰔟 5h ■■□□□□□□□□ 23% │ 󰃭 7d ■■■■□□□□□□ 41% │ 󰑐 1hr 56m
#
# Powerline の起点・区切り・終端のグリフは行ごとに切り替えられないため、
# 背景なしのプレーンな行にしたいときは、この行全体を 1 つのウィジェットで出す。
# バーの描画は同じディレクトリの context-bar.sh を使う。
set -u

dir="$(cd "$(dirname "$0")" && pwd)"
sep=" │ "
input="$(cat)"

# 5時間枠のリセットまでの残り時間
reset_text() {
    local at now left
    if command -v jq >/dev/null 2>&1; then
        at="$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty' 2>/dev/null)"
    else
        at="$(printf '%s' "$input" | python3 -c 'import json,sys
v=json.load(sys.stdin).get("rate_limits",{}).get("five_hour",{}).get("resets_at")
print("" if v is None else v)' 2>/dev/null)"
    fi
    [[ -z "$at" ]] && return 0
    now="$(date +%s)"
    left=$(( ${at%.*} - now ))
    (( left < 0 )) && left=0
    if (( left >= 3600 )); then
        printf '󰑐 %dhr %dm' $(( left / 3600 )) $(( left % 3600 / 60 ))
    else
        printf '󰑐 %dm' $(( left / 60 ))
    fi
}

parts=()
five="$(printf '%s' "$input" | "$dir/context-bar.sh" squares 10 "󰔟 5h" five_hour)"
week="$(printf '%s' "$input" | "$dir/context-bar.sh" squares 10 "󰃭 7d" seven_day)"
reset="$(reset_text)"
[[ -n "$five" ]] && parts+=("$five")
[[ -n "$week" ]] && parts+=("$week")
[[ -n "$reset" ]] && parts+=("$reset")

# 1 つも取れないときは何も出さない
(( ${#parts[@]} == 0 )) && exit 0

out=""
for p in "${parts[@]}"; do
    [[ -n "$out" ]] && out+="$sep"
    out+="$p"
done
printf '%s' "$out"
