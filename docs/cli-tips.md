# CLI ツールの組み合わせ方

fzf / zoxide / ripgrep / fd / bat / eza を組み合わせた便利な使い方のメモ。
各ツールは [Brewfile](../Brewfile) で入る。

## 設定済みのもの

`zsh/.zshrc` で次の状態になっている。

| 操作 | 内容 |
| --- | --- |
| `Ctrl-R` | fzf で履歴をあいまい検索 |
| `Ctrl-T` | fzf でファイルを選び、パスをコマンドラインに挿入 |
| `Alt-C` | fzf でディレクトリを選んで `cd`（macOS は端末側で Option を Meta 扱いにする必要がある） |
| `z <語>` | 移動履歴から頻出ディレクトリへ移動 |
| `zi` | 移動履歴を fzf で絞り込んで移動 |
| `ls` / `ll` / `lt` | eza に置き換え済み |

`FZF_DEFAULT_COMMAND` などの fzf 用の環境変数は設定していない。
そのため `Ctrl-T` は fzf 標準の探索（`.gitignore` を考慮しない）になる。

## 各ツールの基本

### fd（find の代替）

```bash
fd foo                  # 名前に foo を含むものを再帰的に探す（.gitignore を尊重）
fd -e md                # 拡張子 md のファイル
fd -t d                 # ディレクトリだけ
fd -H -I foo            # 隠しファイルと .gitignore 対象も含める
fd -e png -x ls -lh     # 見つけたファイルごとにコマンドを実行（-X なら全件を1回でまとめて渡す）
```

### ripgrep（grep の代替）

```bash
rg foo                  # カレント以下を再帰検索（.gitignore を尊重、小文字のみなら大文字小文字を無視）
rg -l foo               # 一致したファイル名だけ
rg -C 3 foo             # 前後 3 行も表示
rg -t md foo            # Markdown だけ対象（rg --type-list で一覧）
rg -g '!*.lock' foo     # glob で除外
rg --hidden foo         # 隠しファイルも対象
```

### bat（cat の代替）

```bash
bat file                # 構文ハイライトと行番号付き
bat -p file             # 装飾なし（コピーしたいとき）
bat -r 10:30 file       # 10〜30 行目だけ
git --help | bat -l help -p   # --help の出力を色付きで読む
```

### zoxide

```bash
z dot                   # 履歴から dot を含む最頻出のディレクトリへ
z a b                   # 複数語は全部に一致するものへ
zi                      # 候補を fzf で選ぶ
zoxide query -l         # 学習済みの一覧
```

## 組み合わせ

fzf は「標準入力の行を絞り込んで、選んだ行を標準出力に返す」だけのフィルタ。
他のコマンドの出力をつなぐと用途が広がる。

### ファイルを探して開く

```bash
# fd で候補を出し、bat のプレビューを見ながら選んで nvim で開く
nvim "$(fd -t f | fzf --preview 'bat --color=always --line-range :200 {}')"

# 複数選択（Tab で選択）して全部開く
fd -t f | fzf -m --preview 'bat --color=always {}' | xargs -o nvim
```

`xargs -o` は子プロセスに端末をつなぎ直す指定。エディタを xargs 経由で開くときに必要。

### ディレクトリへ移動する

```bash
cd "$(fd -t d | fzf)"          # 配下のディレクトリを選んで移動
cd "$(fd -t d -d 3 . ~/Projects | fzf)"   # 範囲を絞って選ぶ
```

履歴から飛ぶなら `zi`、配下を辿るなら上の `fd | fzf`、と使い分ける。

### 中身を検索して該当行をエディタで開く

```bash
# rg の結果（ファイル:行:内容）を fzf で絞り、選んだ行へジャンプして nvim で開く
rg -n --no-heading --color=never '' \
  | fzf -d: --preview 'bat --color=always -H {2} {1}' \
  | awk -F: '{print "+"$2, $1}' \
  | xargs -o nvim
```

入力するたびに rg を再実行する「ライブ grep」にもできる。

```bash
fzf --ansi --disabled --delimiter : \
  --bind 'change:reload:rg -n --no-heading --color=always {q} || true' \
  --preview 'bat --color=always -H {2} {1}'
```

`--disabled` は fzf 自身の絞り込みを止め、検索を rg に任せる指定。

### git と組み合わせる

```bash
git switch "$(git branch --format='%(refname:short)' | fzf)"   # ブランチをあいまい検索で切り替え
git log --oneline | fzf --preview 'git show --color=always {1}'  # コミットを選んで中身を見る
git ls-files | fzf -m | xargs git add                           # 変更を選んでステージ
```

### プロセスを選んで終了する

```bash
ps aux | fzf | awk '{print $2}' | xargs kill
```

## 補足

- 上の例は `.zshrc` に関数やエイリアスとして入れると手間が減る。現状は入れていない
- fzf の候補の出し方は環境変数で変えられる。使い分けは次のとおり
  - `FZF_DEFAULT_COMMAND`: `fzf` を単独で実行したとき（標準入力が無いとき）の候補
  - `FZF_CTRL_T_COMMAND`: `Ctrl-T` の候補（`FZF_DEFAULT_COMMAND` は見ない）
  - `FZF_ALT_C_COMMAND`: `Alt-C` の候補（同上）
- `.gitignore` を尊重させるなら、`.zshrc` の fzf の節で次のように設定する

  ```bash
  export FZF_DEFAULT_COMMAND='fd --type f'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d'
  ```

- fzf 内の操作: `Ctrl-N` / `Ctrl-P`（または矢印）で移動、`Tab` で複数選択、`Esc` で中止
- ツールのキー操作や設定の詳細は、各ツールの `--help` または公式ドキュメントを参照
