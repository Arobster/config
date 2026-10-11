# ~/.bash_profile
# Windows Git Bash bootstrap: load the canonical Bash configuration stored
# in OneDrive. The canonical .bashrc is responsible for loading .bash_aliases.

CANONICAL_BASHRC="$HOME/OneDrive/Documents/Programming/config/bash/.bashrc"

if [ -f "$CANONICAL_BASHRC" ]; then
    source "$CANONICAL_BASHRC"
fi
