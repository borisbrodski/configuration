export EDITOR=vim

alias ll='ls -l'
alias la='ls -la'
alias lf='ls -F'

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."
alias ........="cd ../../../../../../.."
alias .........="cd ../../../../../../../.."
alias ..........="cd ../../../../../../../../.."

alias vf='sh -c "vim \$(find -iname \"*\$0*.\$1*\") "'

function mkdirc {
        mkdir $1
        cd $1
}
