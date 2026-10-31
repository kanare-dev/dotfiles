# ============================================================
# PATH (foundation)
# ============================================================
# 思想: ユーザーローカルのbinを最優先に配置する
# - システムやパッケージマネージャーのbinより優先
# - カスタムスクリプトや手動インストールツールを優先的に使用
# - インストーラが追記する PATH もここにまとめる（読み込み順を一か所で把握するため）
typeset -U path PATH
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)

# ============================================================
# Environment
# ============================================================
# 思想: 環境変数は PATH の直後にまとめ、以降の設定から参照できるようにする

# default editor (used by git, less, crontab -e, etc.)
export EDITOR="nvim"
export VISUAL="$EDITOR"

# git commit signing key lives in the standard macOS ssh-agent (see ~/.ssh/config Host * block)

# ============================================================
# secrets (do not commit)
# ============================================================
# 思想: 秘密情報は dotfiles に入れず、ホーム直下のローカルファイルで管理する
# - リポジトリ配下に置かない（誤コミット/漏洩リスクを下げる）
# - 存在しない場合はエラーにせず静かにスキップ（環境差に強くする）
if [[ -f "$HOME/.zshrc.secret" ]]; then
  source "$HOME/.zshrc.secret"
fi

# ============================================================
# History
# ============================================================
# 思想: 履歴は貴重な資産。大量に保持し、セッション間で共有する
# - 10万件の履歴を保持（長期間の作業履歴を検索可能に）
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

# SHARE_HISTORY は INC_APPEND_HISTORY の動作（即時追記）を含むため、後者は指定しない
setopt SHARE_HISTORY        # 全セッションで履歴を即座に共有（複数ターミナルで同期）

# 履歴の質をさらに上げる（任意）
# HIST_IGNORE_ALL_DUPS は連続重複の除去（HIST_IGNORE_DUPS）を包含する
setopt HIST_IGNORE_ALL_DUPS # 履歴全体で重複を減らす
setopt EXTENDED_HISTORY     # タイムスタンプ等を保存（あとで見返しやすい）
setopt HIST_REDUCE_BLANKS   # 余計な空白を除去

# ============================================================
# Completion (zsh builtin)
# ============================================================
# 思想: Zsh 標準補完を有効化し、速度と品質を両立する
autoload -Uz compinit
# -C: 初回に dump を作り、以降は更新チェックを省略して高速化
#     補完が壊れたら `rm -f ~/.zcompdump* && compinit` で再生成
compinit -C

# 補完の品質（挙動）
setopt AUTO_MENU        # 候補があれば自動でメニュー
setopt COMPLETE_IN_WORD # 単語途中でも補完
setopt ALWAYS_TO_END    # 補完後カーソルを末尾へ

# 代表的な補完スタイル（好みで調整）
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ============================================================
# エイリアス
# ============================================================
# 思想: よく使うコマンドは「安全」と「見やすさ」をデフォルトにする

# 破壊系は “安全版” を別名で（rmを上書きしない方が事故が少ない）
alias rmi='rm -i'
alias mvi='mv -i'
alias cpi='cp -i'

# --- ディレクトリ移動 ---
alias h='cd ~'
alias cdp='cd ~/Projects'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
# ディレクトリを作って即移動（-p で中間ディレクトリもまとめて作成）
# 引数は1つだけ受け付ける（スペースを含む名前はクォートする。誤入力は黙って通さずエラーにする）
mkcd() {
  if (( $# != 1 )); then
    print -u2 "usage: mkcd <dir>"
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1"
}

# --- ファイル一覧表示 ---
# eza があれば見やすく
# eza の有無は ls の定義だけで吸収する（ll/la/lla は ls 経由なので分岐の外に置ける）
# ツリー表示は標準の ls に無いため、eza があるときだけ定義する
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons"

  lt() { command eza --tree --icons "$@"; }
  # ツリー表示に詳細(パーミッション・サイズ・更新日時)を付ける。深いときは llt -L 2 のように階層を絞る
  llt() { lt -l "$@"; }
fi

alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'

# cdしたら中身が見える（eza/lsどっちでもOK）
# 非対話シェル（TTYなし）では発火させない: eza --icons が端末問い合わせでハングする事故を防ぐため
chpwd() { [[ -t 1 ]] && ls; }

# --- Git ---
# gはgitに割り当てる（頻度が最も高いため最短のキーを充てる）
alias g='git'
alias ga='git add'
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gco='git checkout'
alias gb='git branch'
alias gp='git push'
alias gf='git fetch'

# --- grep ---
alias gr='grep'

# --- Claude ---
if command -v claude >/dev/null 2>&1; then
  alias cc='claude'
fi

# ============================================================
# fzf (history/search core)
# ============================================================
# 思想: 履歴検索は必須機能。柔軟にインストール方法に対応し、必須ではない
# - 複数のインストール方法に対応（手動インストール、Homebrew）
# - 存在しない場合はエラーにせずスキップ（ポータブルな設定）
# - 大量の履歴を効率的に検索するためのコアツール
if command -v fzf >/dev/null 2>&1; then
  if [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
  elif command -v brew >/dev/null 2>&1; then
    FZF_BASE="$(brew --prefix)/opt/fzf"
    [[ -f "$FZF_BASE/shell/completion.zsh" ]] && source "$FZF_BASE/shell/completion.zsh"
    [[ -f "$FZF_BASE/shell/key-bindings.zsh" ]] && source "$FZF_BASE/shell/key-bindings.zsh"
  else
    # Linux (apt 等): fzf 0.48+ は自身がシェル統合を出力する
    source <(fzf --zsh 2>/dev/null) 2>/dev/null
  fi
fi

# ============================================================
# zoxide（ディレクトリ移動補助）
# ============================================================
# 思想: ディレクトリ移動を補助する
# - zoxideコマンドが存在する場合のみ有効化
# - 存在しない場合はスキップ（エラーにならない）
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# ============================================================
# direnv（環境変数切り替え支援）
# ============================================================
# 思想: プロジェクトごとに必要な環境変数を自動で切り替える
# - direnvコマンドが存在する場合のみ有効化
# - 存在しない場合はスキップ（エラーにならない）
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# ============================================================
# yazi（ファイルマネージャ）
# ============================================================
# 思想: yazi 終了時に、最後にいたディレクトリへシェルも移動する
# - `y` で起動し、終了(q)すると yazi で開いていた場所に cd する（Q は cd しない）
# - yazi コマンドが存在する場合のみ有効化
if command -v yazi >/dev/null 2>&1; then
  function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi

# ============================================================
# broot（シェル統合）
# ============================================================
# 思想: ツールが要求するシェル統合は、対象が存在するときだけ読み込む
[[ -f "$HOME/.config/broot/launcher/bash/br" ]] && source "$HOME/.config/broot/launcher/bash/br"

# ============================================================
# Prompt (visual)
# ============================================================
# 思想: 視覚的な設定は最後寄りに読み込む（他の設定に影響を与えない）
# - プロンプトは見た目だけの機能なので、機能的な設定の後に配置
# - 存在しない場合はスキップ（必須ではない装飾機能）
# - zsh-syntax-highlighting だけはさらに後ろ（次のセクション）
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ============================================================
# zsh-補完・強調表示（視認性強化系, last）
# ============================================================
# zsh-autosuggestions: 入力補完を提案してくれる
# zsh-syntax-highlighting: コマンドの構文を色付け表示
# - Homebrew (macOS) または apt (/usr/share) でインストールされている場合のみ有効化
# - 存在しない場合はスキップ（エラーにならない）
ZSH_PLUGIN_DIRS=(/usr/share)
command -v brew >/dev/null 2>&1 && ZSH_PLUGIN_DIRS=("$(brew --prefix)/share" $ZSH_PLUGIN_DIRS)

for _dir in $ZSH_PLUGIN_DIRS; do
  if [[ -f "$_dir/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    # デフォルトのANSIグレーはテーマの背景色と被って見づらいことがあるため、
    # TokyoNight のコメント色を直指定して視認性を確保する
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#565f89'
    source "$_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"
    break
  fi
done

# zsh-syntax-highlighting はできるだけ最後に読むのが推奨
for _dir in $ZSH_PLUGIN_DIRS; do
  if [[ -f "$_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    break
  fi
done
unset _dir
