{
  description = "DBeaver.app wrapper using Nix";

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

        icon = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/dbeaver/dbeaver/master/plugins/org.jkiss.dbeaver.core/icons/dbeaver256.png";
          sha256 = "sha256-E6PgklcblsW1p3Vq+oFsFVUypYrPOM4BBOatPUuDqgk=";
        };

        appBundle = pkgs.buildApp {
          name = "DBeaver";
          icon = icon;
          program = "${dbeaver}/bin/dbeaver";
        };
      in
      {
        packages.${system}.default = appBundle;

        apps.${system}.default = {
          type = "app";
          program = "${appBundle}/Applications/DBeaver.app/Contents/MacOS/DBeaver";
        };
      }
    );
}
