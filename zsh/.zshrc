#@@ -1,203 +1 @@

# Source zsh plugins
source $HOME/.config/.zsh-vi-mode/zsh-vi-mode.plugin.zsh

if [ $(ps ax | grep "[s]sh-agent" | wc -l) -eq 0 ] ; then
    eval $(ssh-agent -s) > /dev/null
    if [ "$(ssh-add -l)" = "The agent has no identities." ] ; then
        # Auto-add ssh keys to your ssh agent
        # Example:
        ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github > /dev/null 2>&1
        ssh-add --apple-use-keychain ~/.ssh/id_rsa_devops > /dev/null 2>&1
    fi
fi

# Node- sass
export SKIP_SASS_BINARY_DOWNLOAD_FOR_CI=true
export SKIP_NODE_SASS_TESTS=true

# Yabai
export YABAI_CERT=yabai-cert

#job
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`

# Path to your dotfiles.
export DOTFILES=$HOME/.dotfiles

# Set helix as EDITOR
export EDITOR=hx
# export OPENAI_API_KEY=$(security find-generic-password -s 'openapi token' -w)

MOZ_DISABLE_SAFE_MODE_KEY=1

export ZSH_CUSTOM=$DOTFILES
# export LANG=en_US.UTF-8
# export LC_ALL=$LANG

# fzf
export FZF_DEFAULT_OPTS='
    --reverse
    --border=sharp
    --preview-window=border-sharp
    --ansi
    --header-first
    --scrollbar='▍'
    --color=bg+:-1,spinner:#f5e0dc,hl:#89b4fa,border:#cdd6f4,fg:#7f849c,header:#a6e3a1,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#89b4fa
'

# Git Stuff
LOG_HASH="%C(always,yellow)%h%C(always,reset)"
LOG_RELATIVE_TIME="%C(always,green)(%ar)%C(always,reset)"
LOG_AUTHOR="%C(always,blue)<%an>%C(always,reset)"
LOG_REFS="%C(always,red)%d%C(always,reset)"
LOG_SUBJECT="%s"

LOG_FORMAT="$LOG_HASH}$LOG_AUTHOR}$LOG_RELATIVE_TIME}$LOG_SUBJECT $LOG_REFS"

BRANCH_PREFIX="%(HEAD)"
BRANCH_REF="%(color:red)%(color:bold)%(refname:short)%(color:reset)"
BRANCH_HASH="%(color:yellow)%(objectname:short)%(color:reset)"
BRANCH_DATE="%(color:green)(%(committerdate:relative))%(color:reset)"
BRANCH_AUTHOR="%(color:blue)%(color:bold)<%(authorname)>%(color:reset)"
BRANCH_CONTENTS="%(contents:subject)"

BRANCH_FORMAT="}$BRANCH_PREFIX}$BRANCH_REF}$BRANCH_HASH}$BRANCH_DATE}$BRANCH_AUTHOR}$BRANCH_CONTENTS"


# FUNCTIONS --------------------------------------------------------------

function fo() {
    hx $(find -type f | fzf -m --preview="bat --color=always --style=numbers --line-range=:500 {}")
}
function fcd() {
    cd && cd "$(find -type d | fzf --preview="et -I -H {}" --bind="space:toggle-preview" --preview-window=:hidden)"
}

function fm() {
    find -type d | \
    fzf \
    --bind "enter:become(hx {})" \
    --bind "del:execute(rm -ri {})" \
    --bind "?:toggle-preview" \
    --bind "ctrl-d:change-prompt(Dirs > )" \
    --bind "ctrl-d:+reload(find -type d)" \
    --bind "ctrl-d:+change-preview(et -I {})" \
    --bind "ctrl-f:change-prompt(Files > )" \
    --bind "ctrl-f:+reload(find -type f)" \
    --bind "ctrl-f:+change-preview(bat {})" \
    --header "CTRL+R to delete | ENTER to run hx | DEL to delete | CTRL-D to display directories | CTRL-F to display files" \
    --height 50% --border --margin 5% --preview-window hidden --preview "et -I {}" --prompt "Dirs > "
}

show_git_head() {
    pretty_git_log -1
    git show -p --pretty="tformat:"
}

pretty_git_log() {
    git log --since="6 months ago" --graph --pretty="tformat:${LOG_FORMAT}" $* | pretty_git_format | git_page_maybe
}

pretty_git_log_all() {
    git log --all --since="6 months ago" --graph --pretty="tformat:${LOG_FORMAT}" $* | pretty_git_format | git_page_maybe
}


pretty_git_branch() {
    git branch -v --color=always --format=${BRANCH_FORMAT} $* | pretty_git_format
}

pretty_git_branch_sorted() {
    git branch -v --color=always --format=${BRANCH_FORMAT} --sort=-committerdate $* | pretty_git_format
}

pretty_git_format() {
    # Replace (2 years ago) with (2 years)
    sed -Ee 's/(^[^)]*) ago\)/\1)/' |
    # Replace (2 years, 5 months) with (2 years)
    sed -Ee 's/(^[^)]*), [[:digit:]]+ .*months?\)/\1)/' |
    # Shorten time
    sed -Ee 's/ seconds?\)/s\)/' |
    sed -Ee 's/ minutes?\)/m\)/' |
    sed -Ee 's/ hours?\)/h\)/' |
    sed -Ee 's/ days?\)/d\)/' |
    sed -Ee 's/ weeks?\)/w\)/' |
    sed -Ee 's/ months?\)/M\)/' |
    # Shorten names
    sed -Ee 's/<Andrew Burgess>/<me>/' |
    sed -Ee 's/<([^ >]+) [^>]*>/<\1>/' |
    # Line columns up based on } delimiter
    column -s '}' -t
}

function prs { 
  GH_FORCE_TTY=100% gh pr list --limit 300 |
  fzf --ansi --preview 'GH_FORCE_TTY=100% gh pr view --comments {1}' --preview-window 'down,70%' --header-lines 3 |
  awk '{print $1}' |
  xargs gh pr checkout
}

git_page_maybe() {
    # Page only if we're asked to.
    if [ -n "${GIT_NO_PAGER}" ]; then
        cat
    else
        # Page only if needed.
        less --quit-if-one-screen --no-init --RAW-CONTROL-CHARS --chop-long-lines
    fi
}

# OTHER ALIASES----------------------------------------------------------------
alias nc="nnn -c"
alias g="gitu"
alias ls="nnn -de"
alias c="clear"
alias gpath="find -type f | fzf | sed 's/^..//' | tr -d '\n' | pbcopy"
alias kp="ps aux | fzf | awk '{print \$2}' | xargs kill"
alias delds="find . -name ".DS_Store" -type f -delete"

# GIT ALIASES -----------------------------------------------------------------
alias gc='git commit'
alias gco='git checkout'
alias ga='git add'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch -D'
alias gcp='git cherry-pick'
alias gd='git diff -w'
alias gds='git diff -w --staged'
alias grs='git restore --staged'
alias gst='git rev-parse --git-dir > /dev/null 2>&1 && git status || exa'
alias gu='git reset --soft HEAD~1'
alias gpr='git remote prune origin'
alias ff='gpr && git pull --ff-only'
alias grd='git fetch origin && git rebase origin/master'
alias gbb='git-switchbranch'
alias gbf='git branch | head -1 | xargs' # top branch
alias gl=pretty_git_log
alias gla=pretty_git_log_all
alias gl="git log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(white)%s%C(reset) %C(green)%an %ar %C(reset) %C(bold magenta)%d%C(reset)'"
alias gla="git log --all --graph --format=format:'%C(bold blue)%h%C(reset) - %C(white)%s%C(reset) %C(bold magenta)%d%C(reset)'"
alias git-current-branch="git branch | grep \* | cut -d ' ' -f2"
alias grc='git rebase --continue'
alias gra='git rebase --abort'
alias gec='git status | grep "both modified:" | cut -d ":" -f 2 | trim | xargs hx -'
alias gcan='gc --amend --no-edit'

alias gp="git push -u 2>&1 | tee >(cat) | grep \"pull/new\" | awk '{print \$2}' | xargs open"
alias gpf='git push --force-with-lease'

alias gbdd='git-branch-utils -d'
alias gbuu='git-branch-utils -u'
alias gbrr='git-branch-utils -r -b develop'
alias gg='git branch | fzf | xargs git checkout'
alias gup='git branch --set-upstream-to=origin/$(git-current-branch) $(git-current-branch)'

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=white,fg=black,bold"

#PATH ------------------------------------------------------------------------
export PATH="$HOME/bin:$PATH"
# Load Composer tools
export PATH="$HOME/.composer/vendor/bin:$PATH"
# Load Node global installed binaries
export PATH="$HOME/.node/bin:$PATH"
# Load Node global installed binaries
export PATH="$HOME/.local/bin:$PATH"
# Use project specific binaries before global ones
export PATH="/usr/local/Cellar/llvm/15.0.5/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="/usr/local/opt/llvm/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.config/sesh/scripts:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"
export PATH="$HOME/.tmux/plugins/t-smart-tmux-session-manager/bin:$PATH"
export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
export PATH="/$HOME/.nvm/versions/node/v16.20.2/bin:$PATH"
export PATH="/$HOME/.nvm/versions/node/v18.18.2/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# zoxide
eval "$(zoxide init zsh)"

# TheFuck
eval $(thefuck --alias)

# Starship
eval "$(starship init zsh)"

# Felix (return to LWD)
source <(command fx --init)

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Automatically run "nvm use" command
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# bun completions
[ -s "/Users/ali/.bun/_bun" ] && source "/Users/ali/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
eval "$(atuin init zsh)"
