# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
export ZSH_THEME="simple"

# Set to this to use case-sensitive completion
# export CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# export DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# export DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# export DISABLE_AUTO_TITLE="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git)

source $ZSH/oh-my-zsh.sh

export PATH=/home/rs/bin:$PATH:/usr/games

# Customize to your needs...
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export SVN_SSH="ssh -l rsv"
export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=' -R '

alias eclipse='GTK2_RC_FILES=/home/rs/.gtkrc-eclipse /home/rs/opt/eclipse/eclipse&!'
alias aa="rsync -z -e ssh alice:/data/www/AdminApp.jar ~/opt/admin-app/AdminApp.jar && java -jar ~/opt/admin-app/AdminApp.jar &!"
alias jconsole="jconsole -J-Djava.rmi.server.ignoreStubClasses=true"                                                                             
alias jvisualvm="jvisualvm -J-Djava.rmi.server.ignoreStubClasses=true" 
alias aps="aptitude -F '%v %V %D (%I) - %p - %d' search "
alias jd="java -Djava.net.preferIPv4Stack=true -jar ~/opt/JDownloader/JDownloader.jar"
alias lbreakout2="xrandr --output LVDS --mode 640x480 && /usr/games/lbreakout2 && xrandr --output LVDS --mode 1024x768"
alias tuxpaint="tuxpaint --fullscreen --native"

function fin {
    find . -iname "*$1*"
}

# run keychain - manages ssh keys
/usr/bin/keychain -q ~/.ssh/id_rsa ~/.ssh/id_dsa
source ~/.keychain/$HOST-sh
