#!/bin/bash
# 外部から追記されがちな設定（zsh / vscode / claude）に未コミットの差分があれば通知する。
# 通知のみで、ファイルは書き換えない。

files=$(git -C "${CLAUDE_PROJECT_DIR:-.}" status --porcelain -- zsh vscode claude/settings.json | awk '{print $2}' | tr '\n' ' ')

if [ -n "$files" ]; then
  printf '{"systemMessage":"未コミットの設定変更があります: %s/tidy で整理できます"}\n' "$files"
fi
