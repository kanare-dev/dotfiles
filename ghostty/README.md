# Ghostty 設定マニュアル

この設定 (`config`) での見た目・操作方法まとめ。

## 見た目 (Appearance)

| 項目 | 値 | 内容 |
| --- | --- | --- |
| `font-size` | `14` | フォントサイズ |
| `font-family` | `JetBrainsMono Nerd Font` → `PlemolJP Console NF` | フォント(2行目は「℃」や日本語用のフォールバック。半角幅で描かれる) |
| `background-opacity` | `0.85` | 背景の不透明度（0〜1、低いほど透過） |
| `background-blur` | `20` | 背景のぼかし強度 |
| `minimum-contrast` | `1.3` | 文字色と背景色の最低コントラスト比 |
| `theme` | `Tomorrow Night` | カラーテーマ（`TokyoNight` はコメントアウトで待機中） |
| `palette` | `8=#626880` | パレット色8番（明るい黒 / グレー）を上書き |
| `cursor-style` | `block` | カーソル形状（ブロック） |
| `cursor-style-blink` | `false` | カーソル点滅なし |
| `mouse-hide-while-typing` | `true` | 入力中はマウスカーソルを隠す |
| `window-padding-balance` | `true` | ウィンドウ余白を均等に配分 |
| `window-padding-x` / `-y` | `6` | ウィンドウ左右・上下の余白 |
| `window-save-state` | `always` | ウィンドウの状態を常に保存・復元 |
| `window-colorspace` | `display-p3` | 広色域カラースペース |

## キーバインド

### 改行

| キー | 動作 |
| --- | --- |
| `Shift+Enter` | 改行を送信（`\x1b\r`）。シェルや REPL などで改行だけ入力したい場合に使用 |

### 単語単位の削除

| キー | 動作 |
| --- | --- |
| `Alt+Backspace` | 単語単位で削除（`\x1b\x7f`） |
| `Shift+Backspace` | 同上 |

### ペイン移動（Vim風）

| キー | 動作 |
| --- | --- |
| `Ctrl+h` / `j` / `k` / `l` | 左/下/上/右のペインへ移動 |

### ペイン分割

| キー | 動作 |
| --- | --- |
| `Ctrl+Shift+v` | 右方向に分割（縦分割） |
| `Ctrl+Shift+h` | 下方向に分割（横分割） |

### ペインを閉じる

| キー | 動作 |
| --- | --- |
| `Ctrl+x` | 現在のペイン（サーフェス）を閉じる |

### ペインのリサイズ

| キー | 動作 |
| --- | --- |
| `Ctrl+,` | 左方向に10リサイズ |
| `Ctrl+.` | 右方向に10リサイズ |
| `Ctrl+;` | 下方向に10リサイズ |
| `Ctrl+'` | 上方向に10リサイズ |

### スクロール

| キー | 動作 |
| --- | --- |
| `Ctrl+Shift+k` | 3行上にスクロール |
| `Ctrl+Shift+j` | 3行下にスクロール |

## その他

- `macos-option-as-alt = left` はコメントアウトで無効化中。有効化すると
  左 `Option` キーが `Alt` として扱われ、tmux / Neovim で `Alt` 修飾キーの
  キーバインドが使えるようになる。
