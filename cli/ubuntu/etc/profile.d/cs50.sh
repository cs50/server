# aliases
alias cp="cp -i"
alias ll="ls -l --color=auto"
alias mv="mv -i"
alias rm="rm -i"

# environment variables
export EDITOR=nano

if [ "$PS1" ]; then
    echo "This is CS50 CLI."
    export PS1="# "
fi
