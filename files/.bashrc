#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
else
        #PROMPT_DIRTRIM=1
		#PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
		PS1='\[\033[01;36m\]\W `if [ $? = 0 ]; then echo "\[\033[01;32m\][✔]"; else echo "\[\033[01;31m\][✘]"; fi` \[\033[00m\]>\[\033[02;32m\]>\[\033[01;36m\]>\[\033[00m\] '
        #PS1='\[\033[01;36m\]\W `if [ $? = 0 ]; then echo "\[\033[01;36m\]>>"; else echo "\[\033[01;31m\]>>"; fi`\[\033[00m\] ' 
        #PS1='\[\033[01;36m\]╭────`if [ $? = 0 ]; then echo "\[\033[01;32m\][✔]"; else echo "\[\033[01;31m\][✘]"; fi`\[\033[01;36m\]───────(\#)───(`time $1`)────[\W]────\[\033[01;33m\]$(git branch 2>/dev/null | cut -d" " -f2)\[\033[01;36m\]────»\n╰─▶\[\033[00m\$ '
fi

### Alias Start
alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MBi

alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -ah'
alias lla='ls -lah'

alias np='nano -w PKGBUILD'
alias more=less
alias sudo='sudo '
# alias lynis='sudo lynis audit system'
alias c='clear'
alias no='nano'
alias pac='sudo pacman -Syuw'
alias you='youtube-dl '
alias you1='yt-dlp '
alias pnew='sudo DIFFPROG=meld pacdiff'
alias call='adb -s ZF6223VF2K shell am start -a android.intent.action.CALL -d tel: '  # to use with ADB
alias backup="~/Documents/backup.sh"
alias dev="cd /mnt/ECF6418FF6415B4A/development/"
alias update-grub='grub-mkconfig -o /boot/grub/grub.cfg'
alias clean='~/.config/scripts/clean.sh'
alias scan='~/.config/scripts/scan'
alias camera='mpv av://v4l2:/dev/video0 --profile=low-latency --untimed'

alias cdt='cd "$(find ~ -type d | fzf)" '
alias cde='cd "$(find /etc -type d | fzf)" '
alias cdm='cd "$(find /media -type d | fzf)" '

alias getpath="find -type f | fzf | sed 's/^..//' | tr -d '\n' | xclip -selection c"

open() {
    xdg-open "$(find -type f | fzf)"
}

expose() {
  sudo iptables -A OUTPUT -p tcp -m tcp --dport $1 -j ACCEPT
}

mk () {
  mkdir $1 && cd $1
}

### Alias End

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases
shopt -s autocd

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

# History Commands
export HISTCONTROL=ignoreboth:erasedumps
export HISTIGNORE='ls*:cd*:c:history*:pac'
export HISTTIMEFORMAT='%d-%m-%Y %T '

