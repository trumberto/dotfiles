umask 022


###
# Options.  See zshoptions(1)
setopt correct
setopt extended_glob
setopt no_case_glob # non case sensitive globbing
setopt append_history # History commands are appended to the existing file instead of overwriting it.
setopt auto_menu
setopt auto_resume # Commands without arguments will first try to resume suspended programs of the same name.
setopt c_bases # Print hex numbers like 0x7F instead of 16#7F
setopt octal_zeroes # print octal numbers like 037 instead of 8#37
setopt extended_history # Puts more info in the history file
setopt hist_ignore_dups # Sequential duplicate commands only get one history entry.
setopt hist_save_no_dups # Only the newest of a set of duplicates (regardless of sequence) is saved to file.
setopt inc_append_history # Commands are added to the history file as they are entered.
setopt list_packed # Use variable width columns for completion options
setopt magic_equal_subst # Do completion on <value> in foo=<value>
setopt nonomatch # Don't error if globbing fails; just leave the globbing chars in.
setopt rm_star_silent # Don't bug me about it if I type 'rm *'.
setopt nohup # let me exit terminal with ^D without terminating running X apps
setopt nocheckjobs
setopt autopushd # automatically push directories on stack
setopt pushd_ignore_dups
setopt auto_cd
setopt auto_list
setopt bad_pattern
setopt zle

##
# Parameters.  See zshparam(1)
FIGNORE=".o:~" # Extensions to ignore for completion.
HISTFILE=~/.zsh_history # Where to save my command history
HISTSIZE=5000 # Remember the last 5000 commands.
LISTMAX=0 # Only ask if completion listing would scroll off screen
LOGCHECK=300 # Check for logins/logouts every 5 minutes
MAILCHECK=0 # Never look at my mail spool.
REPORTTIME=1 # Give timing statistics for programs that take longer than a second to run.
SAVEHIST=3000 # Save the last 3000 commands.
WATCH=notme # Report on any log(in|out)s not from my username.
WATCHFMT='%n %a %l from %m at %T.' # Format to use for watch messages.

###
# Useful functions

# The following lines were added by compinstall

zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list ''
zstyle :compinstall filename '$HOME/.zshrc'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

#popup menu to complete
zstyle ':completion:*' menu select
#sort completion matches by time
zstyle ':completion:*' file-sort time
# ignore CVS files and directories in completion
zstyle ':completion:*:(all-|)files' ignored-patterns '(|*/)CVS'
zstyle ':completion:*:cd:*' ignored-patterns '(*/)#CVS'

#process list completions
zstyle ':completion:*:*:kill:*' menu select

zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'

# With commands like `rm' it's annoying if one gets offered the same filename
# again even if it is already on the command line. To avoid that:
zstyle ':completion:*:rm:*' ignore-line yes

autoload -U compinit 
compinit
# End of lines added by compinstall:new 

#lines suggested by gentoo
autoload -U compinit promptinit bashcompinit
compinit
promptinit
bashcompinit

autoload -U incremental-complete-word
zle -N incremental-complete-word
bindkey "^Xi" incremental-complete-word

zstyle :mime: mailcap ~/.mailcap
autoload -U zsh-mime-setup
zsh-mime-setup

# Makes it easy to type URLs as command line arguments. As you type, the
# input character is analyzed and, if it mayn eed quoting, the current
# word is checked for a URI scheme. If one is found and the current word
# is not already quoted, a blackslash is inserted before the input
# caracter.
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

#zle -N zle-line-init
zle -N zle-keymap-select

autoload -U run-help

autoload -U zargs

###
# Keyboard configuration

# search for zkbd in zshall man page
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey '^[[3~' delete-char
bindkey '^R'    history-incremental-search-backward

bindkey '^[[7~' vi-beginning-of-line   # Home 
bindkey '^[[8~' vi-end-of-line         # End of Line 
bindkey '^[[2~' beep                   # Insert 
bindkey '^[[3~' delete-char            # Del 
bindkey '^[[5~' vi-backward-blank-word # Page Up 
bindkey '^[[6~' vi-forward-blank-word  # Page Down

bindkey -M viins "^H" run-help

bindkey '^[Oc' accept-and-menu-complete # Ctrl+left puts item under the menu bar to command line and jumps to next item (good for multitem selects)

###
# aliases

# My preferred ls settings.
eval `dircolors -b .dir_colors.solarized`
alias ls='ls -F --color=tty'
alias ll="ls -l"
alias sx='startx'
alias aps="aptitude -F '%v %V %D (%I) - %p - %d' search "
alias jd="java -Djava.net.preferIPv4Stack=true -jar ~/opt/JDownloader/JDownloader.jar"
alias lbreakout2="xrandr --output LVDS --mode 640x480 && /usr/games/lbreakout2 && xrandr --output LVDS --mode 1024x768"
alias tuxpaint="tuxpaint --fullscreen --native"

# use vim as man and info browser
function viminfo () { vim -R -c "Info $1 $2" -c "bdelete 1"; }
alias info=viminfo
function vimman () { vim -R -c "Man $1 $2" -c "bdelete 1"; }
alias man=vimman

###
# Environment variables.

# Location of my mailbox.
export MAIL=~/.maildir/.INBOX
export EDITOR='vim'
export QT_XFT=1
export PATH="$PATH:/usr/sbin:/usr/local/bin:/usr/lib/surfraw:$HOME/bin:$HOME/dwm"
export LESSCHARSET=utf-8
# after this less is able to open many different file formats, cool
eval $(lessfile)
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=cs_CZ.UTF-8
export LC_COLLATE=cs_CZ.UTF-8
export LC_MONETARY=cs_CZ.UTF-8
export LC_PAPER=cs_CZ.UTF-8

#export NNTPSERVER="news.felk.cvut.cz"
export NNTPSERVER="nntp.aioe.org"
export FVWMTERMSCREENSESSIONNAME="fvwmtermscreensession"
export SCREENSESSIONNAME="myscreen"
export http_proxy=http://127.0.0.1:8118
export https_proxy=http://127.0.0.1:8118
#export LPDEST=Canon_BJC-250_LPT_1
export LPDEST=Xerox_Phaser_3117_USB_1

###
# Prompt setup
export PS1="[$(print '%{\e[1;32m%}%n@%M:%{\e[1;36m%}%~%{\e[0m%}')] "
if [[ $USER == "root" ]]; then
        export PS1="[$(print '%{\e[1;31m%}%n@%m:%{\e[1;36%}%~%{\e[0m%}')] "
fi


if [[ $TERM == "screen" ]]; then
    function precmd {
	set_screen_title
    }
    function preexec {
    	set_screen_title $1
    }
elif [[ $TERM != "linux" ]]; then
    function precmd {
        set_term_title
    }
    function preexec {
        emulate -L zsh
        local -a cmd; cmd=(${(z)1})
        set_term_title $cmd[1]:t "$cmd[2,-1]"
    }
fi


function set_screen_title {
	print -Pn "\e]2;screen $USER@$HOST:$PWD $*\a"
	print -Pn "\ek$USER@$HOST $*\e\\"
}

function set_term_title {
    print -nR $'\033]0;'$USER@$HOST:$PWD $*$'\a'
}

#autoload colors zsh/terminfo
#if [[ "$terminfo[colors]" -ge 8 ]]; then
#colors
#fi
#for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
#	eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
#	eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
#	(( count = $count + 1 ))
#done
#PR_NO_COLOUR="%{$terminfo[sgr0]%}"
#
#function zle-line-init zle-keymap-select {
#	if [ "$KEYMAP" =~ "vicmd" ]; then
#		PS1="${PR_YELLOW}[$(print "${PR_GREEN}%n@%M:${PR_CYAN}%~")$PR_YELLOW]$PR_NO_COLOUR "
#	else
#		PS1="[$(print "${PR_GREEN}%n@%M:${PR_CYAN}%~"$PR_NO_COLOUR)] "
#	fi
#    zle reset-prompt
#}

#manpage comletion
man_glob () {
	local a
	read -cA a
	if [[ $a[2] = -s ]] then
		reply=( ${^manpath}/man$a[3]/$1*$2(N:t:r) )
	else
		reply=( ${^manpath}/man*/$1*$2(N:t:r) )
	fi
}
#compctl -K man_glob -x 'C[-1,-P]' -m - 'R[-*l*,;]' -g '*.(man|[0-9nlpo](|[a-z]))' + -g '*(-/)' -- man

###
# Other stuff

# allow local connections to X
#xhost +local:root

#switch the console bell off (that beeping when you complete etc)
setterm -blength 0
xset b off


# run keychain - manages ssh keys
/usr/bin/keychain -q ~/.ssh/id_rsa ~/.ssh/id_dsa
source ~/.keychain/$HOST-sh
