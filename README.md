# Linux Setup for developers on CachyOS/mango

## Automated setup

If this is a freshly installed CachyOS `manago` setup, open Terminal using `Super+T` and execute the following.
On `niri` use `Super+Enter`.

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/cnc/refs/heads/main/.local/bin/cnc)"
```

Above script should install essential packages including shell tools and zed editor.

## Installing additional software

For `neovim` setup

```bash
cnc astro
```

For development (uv(python), rustup(rust), vp(node))

```bash
cnc dev
```

Install and configure `docker` with

```bash
cnc docker
```

Install `virt-manager` for creating virtual machines for windows or desktop linux distributions.

```bash
cnc libvirt
```

For simple virtual machines for development, use `incus`. You should install one of docker or incus, not both on the same system. It's a bit tricky get both working consistently through updates.

```bash
cnc incus
```
