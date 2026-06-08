# Linux Setup for developers on CachyOS/mango

## Automated setup script for CachyOS/mango Linux.

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/cmc/refs/heads/main/.local/bin/cmc)"
```

## Manual setup

Clone the repository

```bash
git clone https://github.com/pervezfunctor/cmc.git
```

If you want to only install packages:

```bash
export PATH="$HOME/local/bin:$PATH"
cmc packages
```

For only syncing dotfiles:

```bash
cmc config
```

For development environment setup:

```bash
cmc dev
```

For neovim setup:

```bash
cmc nvim
```
