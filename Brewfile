# Brewfile
#
# 思想: 入れたツールの台帳を兼ねる。`brew leaves` 相当（明示的に入れたもの）だけを書き、
# 依存で入ったものは書かない。macOS 専用（cask）は Brewfile.extra に置く。
# 行末コメントには「何のツールか・どんな特徴か」を1行で書く（コマンド名がパッケージ名と違うものは `cmd:` で示す）。
#
# このファイルは全マシン共通の最小セット（Linux VM でも入れる）。
# 手元の Mac など、重いツールや GUI アプリまで入れるマシンは Brewfile.extra も追加で流す。
#
#   brew bundle --file=Brewfile            # 共通セットを一括インストール
#   brew bundle --file=Brewfile.extra      # 追加セット（必要なマシンだけ）
#
# `brew bundle cleanup` は両方のファイルを合わせて確認する（片方だけだと、もう片方のツールが削除候補に出る）:
#   cat Brewfile Brewfile.extra | brew bundle cleanup --file=-

# ==== シェル・プロンプト ====
brew "starship"                 # 軽量で高速なクロスシェル対応プロンプト（git 状態や言語バージョンを表示）
brew "fzf"                      # コマンドラインのあいまい検索（履歴・ファイル・任意のリストを絞り込む）
brew "zoxide"                   # z: 移動履歴を学習して頻出ディレクトリへ飛ぶ cd の代替
brew "direnv"                   # ディレクトリに入ると .envrc の環境変数を自動で読み込み・解除
brew "zsh-autosuggestions"      # 入力中に履歴から続きを薄く提案（fish 風）
brew "zsh-syntax-highlighting"  # 入力中のコマンドを色付け（存在しないコマンドは赤で表示）
brew "tmux"                     # ターミナルマルチプレクサ（複数のペイン・セッション、切断後も作業を維持）

# ==== コマンドの置き換え・ファイル操作 ====
brew "bat"                      # 構文ハイライトと git 差分表示付きの cat の代替
brew "eza"                      # アイコン・色・git 状態に対応した ls の代替
brew "fd"                       # 簡潔な構文で高速な find の代替（.gitignore を尊重）
brew "ripgrep"                  # rg: 高速な再帰 grep の代替（.gitignore を尊重）
brew "dust"                     # du の代替（ディレクトリごとの容量を棒グラフ付きツリーで表示）
brew "jq"                       # コマンドラインの JSON 処理・整形ツール
brew "yq"                       # jq 風の構文で YAML / JSON / TOML を処理・編集するツール
brew "wget"                     # URL からファイルを取得する HTTP / FTP ダウンローダ
brew "watch"                    # コマンドを一定間隔で繰り返し実行し、出力を更新表示
brew "watchexec"                # ファイルの変更を検知してコマンドを自動で再実行
brew "tealdeer"                 # tldr: コマンドの実用例だけを短く表示する man の補助（Rust 製の高速クライアント）
brew "hyperfine"                # コマンドの実行時間を複数回測って比較するベンチマークツール
brew "just"                     # Makefile より素直な書式のタスクランナー（justfile にコマンドを集約）

# ==== TUI ツール ====
brew "yazi"                     # Rust 製の高速なターミナルファイルマネージャ（プレビュー対応）
brew "poppler"                  # PDF 描画ライブラリ（yazi の PDF プレビューに使用）
brew "broot"                    # br: ディレクトリツリーを絞り込みながら辿るナビゲータ
brew "micro"                    # 直感的なキー操作で使えるターミナルのテキストエディタ
brew "neovim"                   # 拡張性に優れた Vim のフォーク（Lua で設定）
brew "lazygit"                  # git 操作をキーで行えるターミナル UI
brew "bottom"                   # btm: CPU・メモリ・プロセスをグラフで見るシステムモニタ
brew "btop"                     # CPU・メモリ・ディスク・ネットワークを一画面で見るリソースモニタ
brew "htop"                     # top の改良版。対話的に操作できるプロセスビューア
brew "fastfetch"                # OS やハードウェアの情報を見栄え良く表示（neofetch の高速な後継）

# ==== Git・セキュリティ ====
brew "git"                      # 分散型バージョン管理システム
brew "git-delta"                # delta: 構文ハイライトと左右比較に対応した git diff 用ページャ
brew "difftastic"               # difft: 構文木を解釈して構造単位で差分を出す diff（整形のみの変更に惑わされない）
brew "gh"                       # GitHub の CLI（PR・Issue・リポジトリの操作）
brew "glab"                     # GitLab の CLI（MR・Issue・パイプラインの操作）
brew "gitleaks"                 # git リポジトリへのシークレット（鍵・トークン）の混入を検出
brew "age"                      # シンプルで安全なファイル暗号化ツール（GPG の軽量な代替）
brew "sops"                     # YAML / JSON の値だけを暗号化して管理するエディタ（age 等の鍵と併用）

# ==== 言語・ランタイム ====
brew "bun"                      # 高速な JavaScript ランタイム（バンドラ・テスト・パッケージ管理を内蔵）
brew "uv"                       # Rust 製の高速な Python パッケージ・プロジェクト・バージョン管理（pyenv の代替）

# ==== ネットワーク ====
brew "mosh"                     # 回線切断や IP 変更に強い、SSH の代替となるリモートシェル

# moshi-hook は Linux では Homebrew で入れない（公式の手順で ~/.local/bin に入れ、systemd --user のサービスとして常駐させるため）
if OS.mac?
  tap "rjyo/moshi"
  brew "rjyo/moshi/moshi-hook"  # AI コーディングエージェントと Moshi モバイルアプリを中継するデーモン + CLI
end

# ==== 遊び ====
brew "cmatrix"                  # マトリックス風の緑の文字が降る画面を表示
brew "cowsay"                   # 牛（や他のキャラ）が入力した文をしゃべる ASCII アート
brew "fortune"                  # 実行するたびにランダムな格言を表示
brew "lolcat"                   # 出力を虹色に着色（例: fortune | lolcat）
brew "sl"                       # ls を打ち間違える（sl）と蒸気機関車が走る
brew "toilet"                   # 大きな文字や色付きの ASCII アートを出力（figlet 風）
