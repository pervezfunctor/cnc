# Linux Setup for developers on CachyOS/mango

## Automated setup script for CachyOS/mango Linux.

If this is a freshly installed CachyOS Mango setup, open Terminal using `Super+T` and execute the following.

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/cmc/refs/heads/main/.local/bin/cmc)"
```

If you are not on CachyOS/mango, you can still use above setup script, but you need to make fish the default shell.

```bash
sudo chsh -s $(which fish) $(whoami)
```

You can delete this repository after successful installation.

```bash
rm -rf ~/.cmc
```

Above script installs essential shell tools and adds fish configuration to your existing fish setup but does not delete/replace any of your existing configurations.

For `mangowm`, you can add `~/.config/mango/custom.conf` to `~/.config/mango/config.conf`.

```conf
source=~/.config/mango/custom.conf
```

For `niri` wm, you can add `cfg/custom.kdl` to `~/.config/niri/config.kdl`.

```kdl
include "./cfg/custom.kdl"
```

For `alacritty`, add `~/.config/alacritty/custom.toml` to `~/.config/alacritty/alacritty.toml`.

```toml
[general]
import = ["~/.config/alacritty/custom.toml"]
```

## Installing additional software

For `neovim` setup

```bash
cmc nvim
```

For development (uv(python), rustup(rust), vp(node))

```bash
cmc dev
```

Install and configure `docker` with

```bash
cmc docker
```

Install `virt-manager` for creating virtual machines for windows or desktop linux distributions.

```bash
cmc libvirt
```

For simple virtual machines for development, use `incus`. You should install one of docker or incus, not both on the same system. It's a bit tricky get both working consistently through updates.

```bash
cmc incus
```
