set -gx DOT_DIR $HOME/.cachy-mango-config
set -gx XDG_DATA_DIRS $HOME/.flatpak/exports/share $XDG_DATA_DIRS

fish_add_path --global --move \
  $DOT_DIR \
  $DOT_DIR/nu \
  $HOME/.pixi/bin \
  $HOME/bin \
  $HOME/.local/bin \
  $HOME/.vite-plus/bin

function has_cmd
  type -q $argv[1]
end

if ! status is-interactive
  return
end

function fish_greeting
end

if has_cmd nvim
  alias v 'nvim'
  set -gx EDITOR 'nvim'
end

if has_cmd zeditor
  alias zed 'zeditor'
  set -gx VISUAL 'zeditor'
  set -gx EDITOR 'zeditor'
end

alias gs 'git stash'
alias gp 'git push'
alias gb 'git branch'
alias gbc 'git checkout -b'
alias gsl 'git stash list'
alias gst 'git status'
alias gsu 'git status -u'
alias gcan 'git commit --amend --no-edit'
alias gsa 'git stash apply'
alias gfm 'git pull'
alias gcm 'git commit -m'
alias gia 'git add'
alias gco 'git checkout'
alias gh-refresh 'gh auth refresh -h github.com'
function git-tree
    git status --short | awk '{print $2}' | tree --fromfile
end

alias f 'fd'
alias g 'git'
alias h 'btm'
alias t 'tmux'
alias v 'nvim'

alias pi 'pixi global install'

alias fpi 'flatpak install --user flathub'
alias fpr 'flatpak remove --user'
alias fps 'flatpak search'
alias fpu 'flatpak update --user'

alias i 'sudo pacman -S'
alias r 'sudo pacman -R'
alias s 'pacman -Ss'
alias u 'sudo pacman -Syyu'

if has_cmd zoxide
  zoxide init fish | source
end

if has_cmd fzf
  fzf --fish | source
end

if has_cmd starship
  starship init fish | source
end

if has_cmd carapace
  set -gx CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' # optional
  carapace _carapace | source
end

function nu-check
  if test -z "$argv[1]"
    echo "Usage: nu-check <file.nu>"
    return 1
  end
  nu -c "source $argv[1]"
end
