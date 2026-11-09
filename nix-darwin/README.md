# nix-darwin

System config for `Hermann-sin-MacBook-Pro` (aarch64-darwin).
`~/.config/nix-darwin` is a symlink to this folder.

## Apply config changes

After editing `flake.nix`:

```sh
cd ~/.dotfiles/nix-darwin
sudo darwin-rebuild switch --flake .
```

## Update packages

The flake is pinned by `flake.lock` — nothing updates until you bump it.

Update only nixpkgs (e.g. to get a new .NET SDK):

```sh
cd ~/.dotfiles/nix-darwin
nix flake update nixpkgs
sudo darwin-rebuild switch --flake .
```

Update all inputs (nixpkgs + nix-darwin):

```sh
cd ~/.dotfiles/nix-darwin
nix flake update
sudo darwin-rebuild switch --flake .
```

Homebrew casks/brews listed in `flake.nix` are upgraded on switch
(`homebrew.onActivation.upgrade = true`).

Commit `flake.lock` after updating so the pin is tracked.

## Check versions before updating

Version in your current lock vs. latest nixpkgs-unstable:

```sh
nix eval --raw .#darwinConfigurations.Hermann-sin-MacBook-Pro.pkgs.dotnetCorePackages.sdk_10_0.version
nix eval --raw github:NixOS/nixpkgs/nixpkgs-unstable#dotnetCorePackages.sdk_10_0.version
```

Swap `dotnetCorePackages.sdk_10_0` for any package attribute.

## Rollback

```sh
sudo darwin-rebuild --rollback
# or list generations
sudo darwin-rebuild --list-generations
```

Or revert `flake.lock` with git and switch again.

## Cleanup old generations

```sh
sudo nix-collect-garbage --delete-older-than 30d
```
