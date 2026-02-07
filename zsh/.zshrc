# ============================================================
# PATH (foundation)
# ============================================================
# 思想: ユーザーローカルのbinを最優先に配置する
# - システムやパッケージマネージャーのbinより優先
# - カスタムスクリプトや手動インストールツールを優先的に使用
typeset -U path PATH
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)

# ============================================================
# History
# ============================================================
# 思想: 履歴は貴重な資産。大量に保持し、セッション間で共有する
# - 10万件の履歴を保持（長期間の作業履歴を検索可能に）
# - SHARE_HISTORY: 全セッションで履歴を即座に共有（複数ターミナルで同期）
# - INC_APPEND_HISTORY: コマンド実行と同時に履歴に追加（即座に検索可能）
# - HIST_IGNORE_DUPS: 連続する重複コマンドを無視（履歴をクリーンに保つ）
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY INC_APPEND_HISTORY HIST_IGNORE_DUPS

# 履歴の質をさらに上げる（任意）
# - EXTENDED_HISTORY: タイムスタンプ等を保存（あとで見返しやすい）
# - HIST_IGNORE_ALL_DUPS: 履歴全体で重複を減らす
# - HIST_REDUCE_BLANKS: 余計な空白を除去
setopt EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS

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
  fi
fi

# ============================================================
# Prompt (visual, last)
# ============================================================
# 思想: 視覚的な設定は最後に読み込む（他の設定に影響を与えない）
# - プロンプトは見た目だけの機能なので、機能的な設定の後に配置
# - 存在しない場合はスキップ（必須ではない装飾機能）
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ============================================================
# Python
# ============================================================
# 思想: Pythonは必須機能。柔軟にインストール方法に対応し、必須ではない
# - 複数のインストール方法に対応（手動インストール、Homebrew）
# - 存在しない場合はエラーにせずスキップ（ポータブルな設定）
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT" ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
fi
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - 2>/dev/null)"
fi

# ============================================================
# エイリアス
# ============================================================
# 思想: よく使うコマンドは「安全」と「見やすさ」をデフォルトにする

# 破壊系は “安全版” を別名で（rmを上書きしない方が事故が少ない）
alias rmi='rm -i'
alias mvi='mv -i'
alias cpi='cp -i'

# eza があれば見やすく
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons"
  alias li="eza -la --icons --git"

  lt() { command eza --tree --icons "$@"; }
else
  alias li="ls -la"
fi

# cdしたら中身が見える（eza/lsどっちでもOK）
chpwd() { ls; }

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
# direnv（環境変数切り替え支援）
# ============================================================
# 思想: プロジェクトごとに必要な環境変数を自動で切り替える
# - direnvコマンドが存在する場合のみ有効化
# - 存在しない場合はスキップ（エラーにならない）
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi


# ============================================================
# zsh-補完・強調表示（視認性強化系）
# ============================================================
# zsh-autosuggestions: 入力補完を提案してくれる
# zsh-syntax-highlighting: コマンドの構文を色付け表示
# - Homebrew でインストールされている場合のみ有効化
# - 存在しない場合はスキップ（エラーにならない）
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"
  if [[ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
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

# zsh-syntax-highlighting はできるだけ最後に読むのが推奨
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"
  if [[ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  fi
fi

source /Users/canale/.config/broot/launcher/bash/br

# Added by Antigravity
export PATH="/Users/canale/.antigravity/antigravity/bin:$PATH"
