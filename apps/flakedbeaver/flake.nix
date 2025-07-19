{
  description = "Flake for DBeaver using nixpkgs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # or use `nixos-unstable` for latest
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        packages.dbeaver = pkgs.dbeaver;

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.dbeaver ];
        };
      });
}
