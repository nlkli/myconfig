export EDITOR=nvim
alias e='$EDITOR'
alias y='yazi'

bindkey -v

KEYTIMEOUT=1

HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY

autoload -Uz add-zsh-hook
autoload -Uz compinit
compinit

bindkey '^r' history-incremental-search-backward
bindkey '^p' up-line-or-history
bindkey '^n' down-line-or-history

if command -v pbcopy >/dev/null 2>&1; then
  alias clipcopy='pbcopy'
  alias clippaste='pbpaste'
elif command -v wl-copy >/dev/null 2>&1; then
  alias clipcopy='wl-copy'
  alias clippaste='wl-paste'
elif command -v xclip >/dev/null 2>&1; then
  alias clipcopy='xclip -selection clipboard'
  alias clippaste='xclip -selection clipboard -o'
elif command -v xsel >/dev/null 2>&1; then
  alias clipcopy='xsel --clipboard --input'
  alias clippaste='xsel --clipboard --output'
elif command -v clip.exe >/dev/null 2>&1; then
  alias clipcopy='clip.exe'
  alias clippaste='powershell.exe -command Get-Clipboard'
fi

function vi-yank-clipboard {
  zle vi-yank
  print -rn -- "$CUTBUFFER" | clipcopy
}

function vi-put-clipboard-after {
  CUTBUFFER=$(clippaste)
  zle vi-put-after
}

function vi-put-clipboard-before {
  CUTBUFFER=$(clippaste)
  zle vi-put-before
}

function copy-prompt-line-to-clipboard {
  local line="${LBUFFER}${RBUFFER}"
  print -rn -- "$line" | clipcopy
}

zle -N vi-yank-clipboard
zle -N vi-put-clipboard-after
zle -N vi-put-clipboard-before
zle -N copy-prompt-line-to-clipboard

bindkey -M vicmd ' ' undefined-key
bindkey -M vicmd ' y' vi-yank-clipboard
bindkey -M vicmd ' p' vi-put-clipboard-after
bindkey -M vicmd ' P' vi-put-clipboard-before
bindkey -M vicmd '^y' vi-put-clipboard-before
bindkey '^y' copy-prompt-line-to-clipboard

function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    RPS1="%F{red}N%f"
  else
    RPS1="%F{green}I%f"
  fi
  zle reset-prompt
}

zle -N zle-keymap-select
