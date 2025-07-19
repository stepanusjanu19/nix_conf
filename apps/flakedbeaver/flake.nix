{
  description = "DBeaver.app flake wrapper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        dbeaver = pkgs.dbeaver-bin;

        appBundle = pkgs.buildApp {
          name = "DBeaver";
          program = "${dbeaver}/bin/dbeaver";
        };
      in {
        packages.${system}.default = appBundle;

        apps.${system}.default = {
          type = "app";
          program = "${appBundle}/Applications/DBeaver.app/Contents/MacOS/DBeaver";
        };
      }
    );
}
