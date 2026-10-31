# ============================================================
# Overview（全体方針）
# ============================================================
# 思想: どの環境でも壊れず、同じ設定で動く
# - 外部ツールは存在するときだけ有効化する（無い環境でもエラーにしない）
# - セクションは読み込み依存の順に並べる（PATH → Environment → … → Plugins）

# ============================================================
# PATH（基盤）
# ============================================================
# 思想: ユーザーローカルの bin を最優先に配置する
# - システムやパッケージマネージャーの bin より優先し、手動インストールしたツールを使う
# - インストーラが追記する PATH もここにまとめる（読み込み順を一か所で把握するため）
typeset -U path PATH
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)

# ============================================================
# Environment（環境変数）
# ============================================================
# 思想: 環境変数は PATH の直後にまとめ、以降の設定から参照できるようにする

# git / less / crontab -e などが参照する既定のエディタ
export EDITOR="nvim"
export VISUAL="$EDITOR"

# terminfo が無い TERM を持ち込まれたときは xterm-256color に落とす
# - ssh 先に Ghostty の terminfo が無いと、zsh のカーソル移動や行の消去が効かず入力表示が崩れる
if [[ "$TERM" == xterm-ghostty ]] && ! infocmp xterm-ghostty &>/dev/null; then
  export TERM=xterm-256color
fi

# Homebrew の prefix（fzf とプラグインの探索で共有する）
# - 通常は ~/.zprofile の `brew shellenv` が設定済み。未設定のときだけ brew を呼ぶ（fork を避ける）
# - Linuxbrew は公式インストーラが ~/.zprofile を書き換えないため、既定の場所を自分で探して有効化する
if (( ! $+commands[brew] )); then
  for _brew in /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    if [[ -x "$_brew" ]]; then
      eval "$("$_brew" shellenv)"
      break
    fi
  done
  unset _brew
fi
(( $+commands[brew] )) && : ${HOMEBREW_PREFIX:=$(brew --prefix)}

# ============================================================
# Secrets（コミット禁止）
# ============================================================
# 思想: 秘密情報は dotfiles に入れず、ホーム直下のローカルファイルで管理する
# - リポジトリ配下に置かない（誤コミットや漏洩のリスクを下げる）
if [[ -f "$HOME/.zshrc.secret" ]]; then
  source "$HOME/.zshrc.secret"
fi

# ============================================================
# History（履歴）
# ============================================================
# 思想: 履歴は貴重な資産。大量に保持し、セッション間で共有する
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000   # 長期間の作業履歴を検索できるようにする
SAVEHIST=100000

# SHARE_HISTORY は INC_APPEND_HISTORY の動作（即時追記）を含むため、後者は指定しない
setopt SHARE_HISTORY        # 全セッションで履歴を即座に共有（複数ターミナルで同期）

# HIST_IGNORE_ALL_DUPS は連続重複の除去（HIST_IGNORE_DUPS）を包含する
setopt HIST_IGNORE_ALL_DUPS # 履歴全体で重複を減らす
setopt EXTENDED_HISTORY     # タイムスタンプ等を保存（あとで見返しやすい）
setopt HIST_REDUCE_BLANKS   # 余計な空白を除去

# ============================================================
# Completion（zsh 標準補完）
# ============================================================
# 思想: zsh 標準の補完を有効化し、速度と品質を両立する
autoload -Uz compinit
# -C: 初回に dump を作り、以降は更新チェックを省略して高速化
#     補完が壊れたら `rm -f ~/.zcompdump* && compinit` で再生成
compinit -C

setopt AUTO_MENU        # 候補があれば自動でメニュー
setopt COMPLETE_IN_WORD # 単語途中でも補完
setopt ALWAYS_TO_END    # 補完後カーソルを末尾へ

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # 大文字小文字を区別しない

# ============================================================
# Aliases（エイリアス）
# ============================================================
# 思想: よく使うコマンドは「安全」と「見やすさ」をデフォルトにする

# 破壊系は「安全版」を別名で用意する（rm 自体を上書きしない方が事故が少ない）
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
# eza の有無は ls の定義だけで吸収する（ll / la / lla は ls 経由なので分岐の外に置ける）
# ツリー表示は標準の ls に無いため、eza があるときだけ定義する
if (( $+commands[eza] )); then
  alias ls="eza --icons"

  lt() { command eza --tree --icons "$@"; }
  # lt に詳細（パーミッション・サイズ・更新日時）を付ける。深いときは llt -L 2 のように階層を絞る
  llt() { lt -l "$@"; }
fi

# -h は eza では列見出し (--header)、標準の ls では読みやすいサイズ表示になる（どちらでも無害）
alias ll='ls -lh'
alias la='ls -a'
alias lla='ls -lah'

# cd したら中身を表示する（eza / ls どちらでも動く）
# 非対話シェル（TTY なし）では発火させない: eza --icons が端末問い合わせでハングする事故を防ぐため
chpwd() { [[ -t 1 ]] && ls; }

# --- Git ---
# g は git に割り当てる（頻度が最も高いため最短のキーを充てる）
alias g='git'
alias ga='git add'
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gco='git checkout'
alias gb='git branch'
alias gp='git push'
alias gf='git fetch'

# --- Claude ---
# cc はシステムの C コンパイラ (/usr/bin/cc) と衝突するため cl にする
if (( $+commands[claude] )); then
  alias cl='claude'
fi

# ============================================================
# fzf（履歴・検索）
# ============================================================
# 思想: 履歴検索の中核。インストール方法の違い（手動 / Homebrew / apt）を吸収する
if (( $+commands[fzf] )); then
  if [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
  elif [[ -n "$HOMEBREW_PREFIX" ]]; then
    FZF_BASE="$HOMEBREW_PREFIX/opt/fzf"
    [[ -f "$FZF_BASE/shell/completion.zsh" ]] && source "$FZF_BASE/shell/completion.zsh"
    [[ -f "$FZF_BASE/shell/key-bindings.zsh" ]] && source "$FZF_BASE/shell/key-bindings.zsh"
  else
    # Linux (apt 等): fzf 0.48 以降は自身がシェル統合を出力する
    source <(fzf --zsh 2>/dev/null) 2>/dev/null
  fi
fi

# ============================================================
# zoxide（ディレクトリ移動）
# ============================================================
# 思想: 移動履歴から頻出ディレクトリへ素早く移動する
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# ============================================================
# direnv（環境変数の切り替え）
# ============================================================
# 思想: プロジェクトごとに必要な環境変数を自動で切り替える
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# ============================================================
# yazi（ファイルマネージャ）
# ============================================================
# 思想: yazi 終了時に、最後にいたディレクトリへシェルも移動する
# - `y` で起動し、終了 (q) すると yazi で開いていた場所に cd する（Q は cd しない）
if (( $+commands[yazi] )); then
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
# Prompt（見た目）
# ============================================================
# 思想: 視覚的な設定は最後寄りに読み込む（機能的な設定に影響を与えない）
# - 見た目だけの機能なので、機能的な設定の後に配置する
# - zsh-syntax-highlighting だけはさらに後ろ（Plugins セクション）
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

# ============================================================
# Plugins（入力補完・構文ハイライト）
# ============================================================
# 思想: 入力の視認性を上げるプラグインは、他の設定がすべて済んだ最後に読み込む
# - zsh-autosuggestions: 入力中に履歴から補完候補を提案する
# - zsh-syntax-highlighting: コマンドの構文を色付けする
# - Homebrew (macOS) または apt (/usr/share) のインストール先から探す
ZSH_PLUGIN_DIRS=(/usr/share)
[[ -n "$HOMEBREW_PREFIX" ]] && ZSH_PLUGIN_DIRS=("$HOMEBREW_PREFIX/share" $ZSH_PLUGIN_DIRS)

for _dir in $ZSH_PLUGIN_DIRS; do
  if [[ -f "$_dir/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    # デフォルトの ANSI グレーはテーマの背景色と被って見づらいことがあるため、
    # TokyoNight のコメント色を直指定して視認性を確保する
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#565f89'
    source "$_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"
    break
  fi
done

# zsh-syntax-highlighting は、できるだけ最後に読むのが推奨されている
for _dir in $ZSH_PLUGIN_DIRS; do
  if [[ -f "$_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    break
  fi
done
unset _dir
