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

# FUNCTION - del remote branch del_branch(branchA)
del_branch() {
    # git push -u origin Branchname
    git push origin --delete $1
    git branch -D $1
}

# ALIASES
alias dir2="cd '//server/dir1/dir2/'"
alias tk="cd '/c/Users/RobertsA/projects/toolkit'"
alias test_env="conda activate /c/Users/RobertsA/.envs/test;cd '/c/Users/RobertsA/projects/toolkit'"

# SOURCE ALIASES
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi
