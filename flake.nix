{
  description = "mac os flake";
  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that say how to build software.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # nixos-22.11

    # Manages configs links things into your home directory
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Controls system level software and settings including fonts
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Tricked out nvim
    pwnvim.url = "github:zmre/pwnvim";
  };
  outputs = inputs@{ self, nixpkgs, home-manager, darwin, pwnvim, ... }:
    let 
      system = "x86_64-darwin";
      username = "mac";
    in{
      darwinConfigurations.kei19_resdina = darwin.lib.darwinSystem {
        inherit system;

        pkgs = import nixpkgs { 
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
        modules = [
          ./modules/darwin
          home-manager.darwinModules.home-manager
          {

            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            users.users.${username} = {
              home = "/Users/${username}";
            };

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit pwnvim; };
              users.${username}.imports = [ ./modules/home-manager ];
            };
          }
        ];
      };
    };
}
