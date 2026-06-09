# Linux Setup for developers on CachyOS/mango

## Automated setup script for CachyOS/mango Linux.

Following script will install essential packages and sync dotfiles. Most of your dotfiles are not touched.

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/cmc/refs/heads/main/.local/bin/cmc)"
```

You can delete this repository after installation.

```bash
rm -rf ~/.cmc
```

For mangowm, you can add `~/.config/mango/custom.conf` to your `~/.config/mango/config.conf` file.

```conf
source=~/.config/mango/custom.conf
```

For niri wm, you can add `cfg/custom.kdl` to your `~/.config/niri/config.kdl` file.

```kdl
include "./cfg/custom.kdl"
```

For alacritty, add `~/.config/alacritty/custom.toml` to your `~/.config/alacritty/alacritty.toml` file.

```toml
[general]
import = ["~/.config/alacritty/custom.toml"]
```

Install and configure docker with

```bash
cmc docker
```

Install virt-manager for creating virtual machines for windows or desktop linux distributions.

```bash
cmc libvirt
```

For simple virtual machines for development, use incus. You cannot install incus after installing docker. This is known to be problematic.

```bash
cmc incus
```

For neovim setup

```bash
cmc nvim
```

For development (uv(python), rustup(rust), vp(node))

```bash
cmc dev
```

## Manual setup

Clone the repository

```bash
git clone https://github.com/pervezfunctor/cmc.git
```

If you want to only install packages

```bash
export PATH="$HOME/local/bin:$PATH"
cmc packages
```

For only syncing dotfiles

```bash
cmc config
```
