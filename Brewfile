# Brewfile
#
# 思想: 入れたツールの台帳を兼ねる。`brew leaves` 相当（明示的に入れたもの）だけを書き、
# 依存で入ったものは書かない。macOS 専用（cask）は OS.mac? で囲み、Linux (Linuxbrew) でも流用できるようにする。
#
#   brew bundle --file=Brewfile            # 一括インストール
#   brew bundle cleanup --file=Brewfile    # Brewfile に無いものを確認（--force で削除）

tap "hashicorp/tap"
tap "rjyo/moshi"

# ==== シェル・プロンプト ====
brew "starship"                  # プロンプト
brew "fzf"                       # あいまい検索
brew "zoxide"                    # 賢い cd
brew "direnv"                    # ディレクトリごとの環境変数
brew "zsh-autosuggestions"       # zsh 入力補完
brew "zsh-syntax-highlighting"   # zsh シンタックスハイライト
brew "tmux"                      # ターミナルマルチプレクサ

# ==== コマンドの置き換え・ファイル操作 ====
brew "bat"                       # cat の代替
brew "eza"                       # ls の代替
brew "fd"                        # find の代替
brew "ripgrep"                   # grep の代替
brew "dust"                      # du の代替
brew "jq"                        # JSON 処理
brew "glow"                      # Markdown ビューア
brew "wget"
brew "watch"
brew "watchexec"                 # ファイル変更で再実行

# ==== TUI ツール ====
brew "yazi"                      # ファイルマネージャ
brew "poppler"                   # yazi の PDF プレビュー用
brew "broot"                     # ツリー型ファイルナビゲータ
brew "micro"                     # 簡易テキストエディタ
brew "neovim"                    # エディタ
brew "lazygit"                   # git TUI
brew "bottom"                    # btm: システムモニタ
brew "btop"                      # システムモニタ
brew "htop"                      # プロセスモニタ
brew "k9s"                       # Kubernetes TUI
brew "fastfetch"                 # システム情報表示

# ==== Git・セキュリティ ====
brew "git"
brew "git-delta"                 # git diff ページャ
brew "gh"                        # GitHub CLI
brew "glab"                      # GitLab CLI
brew "gitleaks"                  # シークレット検出
brew "age"                       # ファイル暗号化
brew "sops"                      # シークレット暗号化

# ==== 言語・ランタイム ====
brew "go"
brew "node"
brew "uv"                        # Python のバージョン・パッケージ・プロジェクト管理 (pyenv の代替)

# ==== インフラ・クラウド ====
brew "awscli"
brew "ansible"
brew "ansible-lint"
brew "yamllint"
brew "hashicorp/tap/terraform"
brew "argocd"
brew "kubernetes-cli"            # kubectl
brew "kind"                      # ローカル Kubernetes

# ==== ネットワーク ====
brew "mosh"
brew "wireguard-tools"
brew "rjyo/moshi/moshi-hook"

# ==== ドキュメント ====
brew "pandoc"
brew "typst"

# ==== 遊び ====
brew "cmatrix"
brew "cowsay"
brew "fortune"
brew "lolcat"
brew "sl"
brew "toilet"

# ==== macOS 専用 (GUI アプリ・フォント) ====
if OS.mac?
  cask "cmux"
  cask "drawio"
  cask "font-jetbrains-mono-nerd-font"
  cask "iterm2"
  cask "macvim-app"
  cask "supercollider"
  cask "warp"
  cask "wireshark-app"
end

# ==== Brew 管理外 (手動で入れたもの) ====
# Claude Code / Ghostty / VSCode など公式インストーラ・dmg で入れたもの
