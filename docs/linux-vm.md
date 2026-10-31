# Linux VM のトラブルシュート

Linux VM（Ubuntu）に dotfiles を入れたときに実際に踏んだ問題と、その対処をまとめる。導入手順は [README](../README.md) の「Linux VM」を参照。

## zsh の入力表示が崩れる

### 症状

- 1 文字打つと 2 文字表示される
- Backspace を押しても文字が残る、または増える
- `clear` が `'xterm-ghostty': unknown terminal type.` で失敗する

### 原因

Mac の Ghostty が `TERM=xterm-ghostty` を ssh 先へ引き継ぐが、VM に Ghostty の terminfo が無い。zsh はカーソル移動や行の消去を terminfo の定義に頼るため、再描画が崩れる。bash は再描画が単純なので表に出にくい。

設定を読まない `zsh -f` でも崩れるなら、`.zshrc` ではなく端末側（`TERM` / terminfo）の問題。

### 対処

`.zshrc` は、terminfo が無いときに `TERM=xterm-256color` へ自動で落とす（保険）。Ghostty 本来の `TERM` を使うなら、Mac 側から terminfo を送る。

```bash
infocmp -x xterm-ghostty | ssh <VMのホスト名> -- tic -x -
```

送った後は VM にログインし直す。

### 切り分けの手順

```bash
echo "$TERM  $LANG"; locale | head -3
exec zsh -f   # 設定なしの zsh。ここで崩れるなら端末側の問題
```

`zsh -f` で正常なら、`.zshrc` のどれが原因かを次の順に 1 つずつ読み込んで確認する。

```bash
eval "$(starship init zsh)"
source /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

## git が SSL エラーになる

### git のエラー内容

```text
fatal: unable to access 'https://github.com/...': SSL certificate OpenSSL verify result: unable to get local issuer certificate (20)
```

### git のエラーの原因

`brew bundle` で Homebrew 版の `git` が入り、PATH の先頭に来る。Homebrew 版は自前の CA 証明書の置き場を見に行くが、`openssl@3` の post-install が失敗していると、その中身が揃わない。

### git のエラーの対処

システムの証明書を使わせる。`--global` だと、リポジトリへのシンボリックリンクである `~/.gitconfig` が書き換わってしまうので、必ず `~/.gitconfig.local` に書く。

```bash
sudo apt install -y ca-certificates   # 入っていなければ
git config -f ~/.gitconfig.local http.sslCAInfo /etc/ssl/certs/ca-certificates.crt
git ls-remote https://github.com/kanare-dev/dotfiles | head -1   # ハッシュが出れば OK
```

一時的に回避するだけなら `apt` 版を直接呼ぶ。

```bash
/usr/bin/git -C ~/dotfiles pull
```

## brew bundle が長い・止まって見える

最近の `brew bundle` は、全部の `Installing` を先に表示してから、まとめてダウンロードや展開をする。止まっているかは別のターミナルで確認する。

```bash
ps aux | grep -E 'brew|curl|make|gcc|cc1|rustc|cargo' | grep -v grep | cut -c1-150
ls -lt ~/.cache/Homebrew/downloads | head -5
```

- `curl` や `brew install` が動き、ファイルが増えていれば順調
- `gcc` や `rustc` が動いていれば、bottle が無くソースビルド中（時間がかかる）
- Ctrl-C で止めても、入った分は `Using` で飛ばされるので再実行できる

## サードパーティのタップが untrusted になる

```text
Error: Refusing to load formula rjyo/moshi/moshi-hook from untrusted tap rjyo/moshi.
```

最近の Homebrew はサードパーティのタップを、信頼を明示するまで読み込まない。必要な formula だけを信頼する。

```bash
brew trust --formula rjyo/moshi/moshi-hook
```

ただし `moshi-hook` は、この VM では公式の手順で `~/.local/bin` に入れ、`systemd --user` のサービスとして常駐させている。そのため `Brewfile` では macOS のときだけ Homebrew で入れる。

## mosh の注意

`mosh` で接続すると、サーバー側の `mosh-server` が ssh 経由の非対話シェルで起動する。このシェルは `.zshrc` を読まないため、Linuxbrew だけに入れた `mosh-server` は PATH に載らず、`mosh-server: command not found` になりうる。`apt` 版（`/usr/bin/mosh-server`）が入っていれば問題ない。UDP 60000〜61000 の開放も必要。
