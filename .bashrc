# PROMPT
export PS1="[\u@\h \W]\\$ "

# VIM
set -o vi
bind '"kj":vi-movement-mode'
export EDITOR="vim"

# CONDA
eval "$('/c/ProgramData/Anaconda3/Scripts/conda.exe' 'shell.bash' 'hook')"
#. /c/ProgramData/Anaconda3/etc/profile.d/conda.sh

# ENV
eval conda activate dev

# SOURCE ALIASES
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# FUNCTION - del remote branch del_branch(branchA)
del_branch() {
    # git push -u origin Branchname
    git push origin --delete $1
    git branch -D $1
}
