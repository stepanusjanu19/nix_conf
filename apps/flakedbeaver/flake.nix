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
        apps.default = {
          type = "app";
          program = "${pkgs.dbeaver-bin}/bin/dbeaver";
        };

        packages.dbeaver = pkgs.dbeaver-bin;

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.dbeaver-bin ];
        };
      });
}
