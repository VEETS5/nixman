{
  description = "nixman: a TUI for managing a multi-host NixOS flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});
    in
    {
      packages = forAll (pkgs: rec {
        nixman = pkgs.callPackage ./package.nix { };
        default = nixman;
      });

      overlays.default = final: _: { nixman = final.callPackage ./package.nix { }; };

      devShells = forAll (pkgs: {
        default = pkgs.mkShell { packages = with pkgs; [ cargo rustc clippy rustfmt rust-analyzer ]; };
      });
    };
}
