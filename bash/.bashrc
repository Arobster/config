# ~/.bashrc
# Canonical interactive Bash configuration intended to work across
# Git Bash, WSL, Raspberry Pi OS, and other typical Linux systems.

# Prevent Python virtual environments from modifying the prompt themselves;
# the custom prompt below displays the active venv explicitly.
export VIRTUAL_ENV_DISABLE_PROMPT=1

# ---------------------------
# VIM / EDITOR
# ---------------------------
set -o vi
bind '"kj":vi-movement-mode'
export EDITOR="vim"

# ---------------------------
# INTERACTIVE CHECK
# ---------------------------
# Prompt, aliases, completion, and convenience functions below are intended
# for terminal sessions where a user is actively entering commands.
# Stop here if Bash is running non-interactively.
case $- in
    *i*) ;;
      *) return ;;
esac

# ---------------------------
# HISTORY / SHELL BEHAVIOR
# ---------------------------
# Ignore duplicate commands and commands beginning with a space.
HISTCONTROL=ignoreboth

# Append to the history file rather than overwriting it.
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# Recalculate terminal dimensions after each command when needed.
shopt -s checkwinsize

# Make less friendlier with non-text input on systems that provide lesspipe.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ---------------------------
# GIT BRANCH PARSER
# ---------------------------
# Displays the current Git branch plus status indicators:
#   + staged changes
#   * modified tracked files
#   ! untracked files
parse_git_branch() {
    git rev-parse --is-inside-work-tree &>/dev/null || return

    local branch status staged modified untracked
    branch=$(git branch --show-current 2>/dev/null)
    [[ -n "$branch" ]] || return

    status=$(git status --porcelain 2>/dev/null)

    [[ -n "$(echo "$status" | grep '^A\|^M\|^MM\|^AM')" ]] && staged="+" || staged=""
    [[ -n "$(echo "$status" | grep '^ M\|^MM\|^AM')" ]] && modified="*" || modified=""
    [[ -n "$(echo "$status" | grep '^??')" ]] && untracked="!" || untracked=""

    printf '(%s%s%s%s)' "$branch" "$staged" "$modified" "$untracked"
}

# ---------------------------
# TWO-LEVEL PATH
# ---------------------------
# Keep the prompt compact by showing at most the final two path components.
two_level_pwd() {
    local dir="$PWD"
    local home="$HOME"

    if [[ "$dir" == "$home" ]]; then
        echo "~"
        return
    elif [[ "$dir" == "$home/"* ]]; then
        local rel="${dir#$home/}"
        local IFS='/'
        local parts
        read -ra parts <<< "$rel"
        local count=${#parts[@]}

        if (( count == 1 )); then
            echo "~/${parts[0]}"
        elif (( count == 2 )); then
            echo "~/${parts[0]}/${parts[1]}"
        else
            echo "~/../${parts[count-2]}/${parts[count-1]}"
        fi
        return
    fi

    local IFS='/'
    local parts
    read -ra parts <<< "$dir"
    local count=${#parts[@]}

    if (( count <= 3 )); then
        echo "$dir"
    else
        echo "/../${parts[count-2]}/${parts[count-1]}"
    fi
}

# ---------------------------
# PROMPT COLORS
# ---------------------------
RED='\[\033[01;31m\]'
GREEN='\[\033[01;32m\]'
YELLOW='\[\033[01;33m\]'
BLUE='\[\033[01;34m\]'
RESET='\[\033[0m\]'

# ---------------------------
# PROMPT (GIT BASH + WSL + LINUX)
# ---------------------------
set_bash_prompt() {
    local venv_part=""
    local git_part=""
    local dir_part
    local venv_name=""

    # Handle both Unix-style '/' and Windows-style '\\' venv paths.
    if [[ -n "$VIRTUAL_ENV" ]]; then
        venv_name="${VIRTUAL_ENV##*/}"
        venv_name="${venv_name##*\\}"
        venv_part="${YELLOW}(${venv_name})${RESET} "
    fi

    dir_part="${BLUE}\u@\h:$(two_level_pwd)${RESET}"

    local git_branch
    git_branch="$(parse_git_branch)"
    [[ -n "$git_branch" ]] && git_part=" ${GREEN}${git_branch}${RESET}"

    PS1="${venv_part}${dir_part}${git_part}\n\$ "
}

PROMPT_COMMAND=set_bash_prompt

# ---------------------------
# ALIASES / COLORS
# ---------------------------
# Enable colored ls/grep output where dircolors is available.
if command -v dircolors >/dev/null 2>&1; then
    test -r ~/.dircolors \
        && eval "$(dircolors -b ~/.dircolors)" \
        || eval "$(dircolors -b)"

    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# ---------------------------
# OPTIONAL CONFIG FILES
# ---------------------------
# Locate companion config files relative to this .bashrc rather than $HOME.
# This allows the canonical files to live together in OneDrive on Windows,
# while also working unchanged if copied together into another directory.
BASH_CONFIG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$BASH_CONFIG_DIR/.bash_aliases" ]; then
    . "$BASH_CONFIG_DIR/.bash_aliases"
fi

# Enable programmable Bash completion when the host system provides it.
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# ---------------------------
# FUNCTIONS
# ---------------------------

# Push a branch to the user's three configured Git remotes.
gitpushall() {
    if [ -z "$1" ]; then
        echo "Error: branch name is required"
        echo "Usage: gitpushall master|dev"
        return 1
    fi

    echo "Pushing branch $1 to all remotes..."
    git push docs "$1" && echo "✓ Pushed to docs"
    git push sandbox "$1" && echo "✓ Pushed to sandbox"
    git push gitlab "$1" && echo "✓ Pushed to gitlab"

    # Historical cleanup commands retained for reference:
    # git push origin --delete "$1"
    # git branch -D "$1"

    echo "Done!"
}

# Push one existing tag to the user's three configured Git remotes.
gitpushalltag() {
    if [ -z "$1" ]; then
        echo "Error: tag name is required"
        echo "Usage: gitpushalltag <tag>"
        return 1
    fi

    # Use Git itself to verify that the requested tag exists locally.
    if ! git rev-parse -q --verify "refs/tags/$1" >/dev/null; then
        echo "Warning: Tag '$1' does not exist"
        echo "Available tags:"
        git tag -l
        return 1
    fi

    echo "Pushing tag $1 to all remotes..."
    git push docs "$1" && echo "✓ Pushed to docs"
    git push sandbox "$1" && echo "✓ Pushed to sandbox"
    git push gitlab "$1" && echo "✓ Pushed to gitlab"
    echo "Done!"
}

# ---------------------------
# OPTIONAL / HISTORICAL PATH REFERENCES
# ---------------------------
# Go (previous WSL setting):
# export PATH="$PATH:/usr/local/go/bin"

# Previous explicit Windows Python 3.13 path (normally unnecessary now):
# export PATH="$PATH:$HOME/AppData/Local/Programs/Python/Python313"

# ---------------------------
# CONDA / ANACONDA REFERENCE (DISABLED)
# ---------------------------
# Retained from older configs for future reference. Nothing in this section
# runs unless deliberately uncommented.
#
# export CONDA_AUTO_ACTIVATE_BASE=false
#
# if [ -f /c/Anaconda3/Scripts/conda.exe ]; then
#     eval "$(/c/Anaconda3/Scripts/conda.exe shell.bash hook)"
# elif [ -f /c/ProgramData/Anaconda3/Scripts/conda.exe ]; then
#     eval "$(/c/ProgramData/Anaconda3/Scripts/conda.exe shell.bash hook)"
# fi
#
# Alternative profile-script approach used previously:
# . /c/ProgramData/Anaconda3/etc/profile.d/conda.sh
#
# Previous environment activation reference:
# conda activate //server/username/envs/conda_dev_py3122
