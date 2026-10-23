#!/usr/bin/env bash
# PostToolUse フック: Claude が編集した Markdown に markdownlint を適用する。
# 思想: 自動修正できるものは黙って直し、直せない警告だけを Claude に返して対応させる。
set -uo pipefail

file="$(jq -r '.tool_input.file_path // empty')"

[[ "$file" == *.md || "$file" == *.markdown ]] || exit 0
[[ -f "$file" ]] || exit 0

# --fix で自動修正し、直せなかった警告だけが出力に残る
if ! output="$(bunx -y markdownlint-cli2 --fix "$file" 2>&1)"; then
    # exit 2 + stderr で Claude に警告がフィードバックされる
    echo "markdownlint の警告が残っています。修正してください:" >&2
    echo "$output" >&2
    exit 2
fi
