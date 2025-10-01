{
  description = "DevShell with Python + Tkinter + Mamba";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-darwin"; # or "aarch64-darwin" if Apple Silicon
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        (pkgs.python3.withPackages (ps:
          with ps; [
            tkinter
            numpy
            pandas
          ]))
        pkgs.mambaforge
      ];
    };
  };
}
