# Linux Setup for developers on CachyOS/mango

## Automated setup

If this is a freshly installed CachyOS Mango setup, open Terminal using `Super+T` and execute the following.

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/cmc/refs/heads/main/.local/bin/cmc)"
```

If you are using any other arch based distro, you can still use above setup script, but you need to make fish the default shell.

```bash
sudo chsh -s $(which fish) $(whoami)
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
