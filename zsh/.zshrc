# Starship
eval "$(starship init zsh)"

# fzf (prefer Homebrew install)
if [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
elif command -v brew >/dev/null 2>&1 && [[ -f "$(brew --prefix)/opt/fzf/shell/completion.zsh" ]]; then
  source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
fi
export PATH="$HOME/.local/bin:$PATH"
