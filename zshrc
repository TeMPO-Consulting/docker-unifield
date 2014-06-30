### INITIAL ZSHRC ###

# Set up the prompt

autoload -Uz promptinit
promptinit
#prompt adam1
PROMPT="%F{white}%n %B%F{magenta}%(4~|...|)%3~%F{white} %# %b%f%k"
RPROMPT="%B%F{blue}%m%k%F{white}"

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

###### END OF INITIAL ZSHRC

#Alias
## Permet la coloration du retour d'un `ls'
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
export GREP_COLORS='ms=01;33:mc=01;33:sl=:cx=:fn=37:ln=32:bn=32:se=36'
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias la='ls $LS_OPTIONS -A'
alias l='ls $LS_OPTIONS -CF'
alias dir='ls $LS_OPTIONS --format=vertical'
alias vdir='ls $LS_OPTIONS --format=long'
alias rgrep='grep -r -n --color'
alias grep='grep --color'

## Evite de faire des erreurs
alias rm='rm -i'
alias cp='cp -i'
#
## Autres alias
alias vi='vim'
alias mem="free -mt"
alias df="df -hT"

### PROPRES À ZSH

## Global aliases (expand whatever their position)
##  e.g. find . E L
alias -g L='| less'
alias -g H='| head'
alias -g S='| sort'
alias -g T='| tail'
alias -g N='> /dev/null'
alias -g E='2> /dev/null'

###### END PROPRES À ZSH
