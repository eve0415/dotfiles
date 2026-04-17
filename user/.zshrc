# PATH

export PATH="/opt/homebrew/bin:$PATH"

# secrets

if [ -f ~/.zsh_secrets ]; then
    source ~/.zsh_secrets
fi


# history
HISTSIZE=10000
SAVEHIST=10000
setopt share_history
setopt hist_ignore_all_dups
setopt auto_cd
setopt prompt_subst
setopt no_beep
setopt interactive_comments

# ---- completion ----

FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes

# ---- keybindings ----

_history_prefix=""
_history_up() {
  [[ $LASTWIDGET != _history_up && $LASTWIDGET != _history_down ]] && _history_prefix=$BUFFER
  CURSOR=${#_history_prefix}
  zle history-beginning-search-backward
  CURSOR=${#BUFFER}
}
_history_down() {
  [[ $LASTWIDGET != _history_up && $LASTWIDGET != _history_down ]] && _history_prefix=$BUFFER
  CURSOR=${#_history_prefix}
  zle history-beginning-search-forward
  CURSOR=${#BUFFER}
}
zle -N _history_up
zle -N _history_down

bindkey "^[[A" _history_up
bindkey "^[[B" _history_down

# external completions
command -v kubectl >/dev/null 2>&1 && source <(kubectl completion zsh)
command -v docker >/dev/null 2>&1 && source <(docker completion zsh)

# ---- plugins ----

# autosuggestions
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# syntax highlight
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ---- prompt (minimal) ----

autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats ' %F{141}%b%f'
zstyle ':vcs_info:*' enable git

PROMPT='%F{39}%~%f${vcs_info_msg_0_} ❯ '

# ---- key mapping ----

# End key
bindkey '\x1b[F' end-of-line
bindkey '\x1b[4~' end-of-line
bindkey '\x1bOF' end-of-line

# Home key
bindkey '\x1b[H' beginning-of-line
bindkey '\x1b[1~' beginning-of-line
bindkey '\x1bOH' beginning-of-line

# ---- aliases ----

alias vi='nvim'
alias vim='nvim'

# ---- fzf improvements ----

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# ---- environment ----

export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
