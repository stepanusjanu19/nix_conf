{
  description = "Flake that provides DBeaver";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        # For `nix run .`
        apps.default = {
          type = "app";
          program = "${pkgs.dbeaver-bin}/bin/dbeaver";
        };

        # For `nix build .#dbeaver` or `nix profile install .#dbeaver`
        packages.dbeaver = pkgs.dbeaver-bin;

        # For `nix develop`
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.dbeaver-bin ];
        };
      });
}
{
  description = "Flake that provides DBeaver";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        # For `nix run .`
        apps.default = {
          type = "app";
          program = "${pkgs.dbeaver-bin}/bin/dbeaver";
        };

        # For `nix build .#dbeaver` or `nix profile install .#dbeaver`
        packages.dbeaver = pkgs.dbeaver-bin;

        # For `nix develop`
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.dbeaver-bin ];
        };
      });
}
