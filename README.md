# nixman

A terminal UI for managing a multi-host NixOS flake: add and remove packages per
machine, update flake inputs, rebuild safely, and keep machines in sync through git.

```
 nixman   1 Packages  2 Flake  3 System  4 Git                  nixpad  ⎇ main ↑0 ↓0
╭ nixpad (this machine) ─────╮╭ System · all — configuration.nix ──────────────────╮
│System · all            41  ││git                                                  │
│Home · all              38  ││ethtool   # NIC link/negotiation diagnostics         │
│System · nixpad          1  ││neovim                                               │
│Home · nixpad            0  ││…                                                    │
```

## Features

- **Packages:** search nixpkgs (`/` from anywhere: name, version, description,
  ✓ for what you already have) and add to a list shared by all machines or to one
  machine only, as a system or home-manager package. Remove, or move packages
  between lists. Duplicates and nonexistent attributes are rejected.
- **Flake:** see each input's revision and age; update one input or all of them.
- **System:** build, show a package diff (nvd), confirm, then switch, test or boot.
  Also rollback, and garbage-collect old generations. nixman **only ever builds
  and activates the configuration for the machine it is running on**, and checks
  that the built system's name matches the hostname before activating it.
- **Git:** status, commit with a message pre-filled from your session's changes
  ("add ncspot (nixtop home); update nixpkgs"), push, pull, fetch, diff, and
  open the repo on GitHub. Warns when the remote has commits you haven't pulled.
- **CLI:** `nixman search QUERY`, `nixman ls`, `nixman add ATTR [--host H] [--home]`,
  `nixman rm ATTR …` for scripting.

## Expected flake layout

nixman edits plain `with pkgs; [ … ]` lists, one attribute per line (comments
are fine; anything more complex inside a list is preserved and left alone):

| List | File | Attribute |
|---|---|---|
| System · all hosts | `configuration.nix` | `environment.systemPackages` |
| Home · all hosts | `home/home.nix` | `home.packages` |
| System · one host | `hosts/<host>/default.nix` | `environment.systemPackages` |
| Home · one host | `hosts/<host>/default.nix` | `home-manager.users.<user>.home.packages` |

Each directory in `hosts/` with a `default.nix` is a host, and its name must
match `nixosConfigurations.<host>` and the machine's hostname. A minimal host
module:

```nix
{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "myhost";
  environment.systemPackages = with pkgs; [
  ];
  home-manager.users.me.home.packages = with pkgs; [
  ];
}
```

The flake is found at `--flake DIR`, then `$NIXMAN_FLAKE`, then `~/.config/nixos`.
The home-manager user is `$NIXMAN_USER`, falling back to `$USER`.

For the System tab to show which commit each generation was built from, add
this to your hosts:

```nix
system.configurationRevision = self.rev or self.dirtyRev or null;
```

## Install

```nix
# flake.nix
inputs.nixman = {
  url = "github:VEETS5/nixman";
  inputs.nixpkgs.follows = "nixpkgs";
};

# in a NixOS module
environment.systemPackages = [ inputs.nixman.packages.${pkgs.stdenv.hostPlatform.system}.default ];
```

Or try it without installing: `nix run github:VEETS5/nixman`.

## Keys

| Tab | Keys |
|---|---|
| Global | `1`–`4`/`Tab` switch tab, `/` search, `r` refresh, `?` help, `q` quit |
| Packages | `a` add, `d` remove, `m` move, `H` edit another host's lists, `←→` focus |
| Flake | `u` update selected input, `U` update all |
| System | `s` switch, `t` test, `B` boot, `b` build and diff, `R` rollback, `g` gc |
| Git | `c` commit, `p` push, `P` pull, `f` fetch, `d` diff, `o` open on GitHub |

The package index is built with `nix search` once per locked nixpkgs revision
(about a minute) and cached in `~/.cache/nixman/`.

## Development

```sh
nix develop
cargo test
```

## License

GPL-3.0-only. See [LICENSE](LICENSE).
