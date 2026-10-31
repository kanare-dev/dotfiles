#!/usr/bin/env bash
# ccstatusline の custom-command ウィジェット用: 使用率をバーで出力する。
# 標準入力に Claude Code のセッション JSON を受け取る。
#
#   context-bar.sh [style] [width] [icon] [field]
#     style: blocks(▰▱) braille(⣿⣀) dots(●○) squares(■□) bars(▮▯)
#            line(━─) diamonds(◆◇) stars(★☆) smooth(1文字を8段階で埋める)
#            既定: blocks
#     width: バーの文字数                           既定: 10
#     icon:  先頭に付けるアイコンやラベル（省略可。空白を含むなら引用符で囲む）
#     field: 何の使用率か  context(既定) / five_hour(5時間枠) / seven_day(週)
set -u

style="${1:-blocks}"
width="${2:-10}"
icon="${3:-}"
field="${4:-context}"

case "$field" in
    context)   jq_path='.context_window.used_percentage' ;;
    five_hour) jq_path='.rate_limits.five_hour.used_percentage' ;;
    seven_day) jq_path='.rate_limits.seven_day.used_percentage' ;;
    *) echo "unknown field: $field" >&2; exit 1 ;;
esac

case "$style" in
    blocks)  full="▰"; empty="▱" ;;
    braille) full="⣿"; empty="⣀" ;;
    dots)    full="●"; empty="○" ;;
    squares) full="■"; empty="□" ;;
    bars)    full="▮"; empty="▯" ;;
    line)    full="━"; empty="─" ;;
    diamonds) full="◆"; empty="◇" ;;
    stars)   full="★"; empty="☆" ;;
    smooth)  full="█"; empty="·" ;;
    *) echo "unknown style: $style" >&2; exit 1 ;;
esac

input="$(cat)"
if command -v jq >/dev/null 2>&1; then
    pct="$(printf '%s' "$input" | jq -r "$jq_path // empty" 2>/dev/null)"
else
    pct="$(printf '%s' "$input" | python3 -c 'import json,sys
v=json.load(sys.stdin)
for k in sys.argv[1].strip(".").split("."):
    v=v.get(k) if isinstance(v,dict) else None
print("" if v is None else v)' "$jq_path" 2>/dev/null)"
fi

# 取得できないとき（セッション開始直後など）は何も出さない
[[ -z "$pct" ]] && exit 0

pct_int="$(printf '%.0f' "$pct")"
(( pct_int < 0 )) && pct_int=0
(( pct_int > 100 )) && pct_int=100

bar=""
if [[ "$style" == "smooth" ]]; then
    # 1文字を 1/8 刻みで埋める（左から ▏▎▍▌▋▊▉█）
    eighths=("" "▏" "▎" "▍" "▌" "▋" "▊" "▉")
    units=$(( pct_int * width * 8 / 100 ))
    cells=$(( units / 8 ))
    rest=$(( units % 8 ))
    for (( i = 0; i < width; i++ )); do
        if (( i < cells )); then
            bar+="$full"
        elif (( i == cells && rest > 0 )); then
            bar+="${eighths[$rest]}"
        else
            bar+="$empty"
        fi
    done
else
    filled=$(( (pct_int * width + 50) / 100 ))
    for (( i = 0; i < width; i++ )); do
        if (( i < filled )); then bar+="$full"; else bar+="$empty"; fi
    done
fi

[[ -n "$icon" ]] && printf '%s ' "$icon"
printf '%s %s%%' "$bar" "$pct_int"
