# Linux Setup for developers on CachyOS/mango

## Automated setup

If this is a freshly installed CachyOS `manago` setup, open Terminal using `Super+T` and execute the following.
On `niri` use `Super+Enter`.

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/cmc/refs/heads/main/.local/bin/cmc)"
```

Above script should install essential packages including shell tools and zed editor.

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
