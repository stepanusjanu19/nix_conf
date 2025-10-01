{
  description = "Python + Tkinter devshell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: {
    devShells.default = nixpkgs.lib.mkShell {
      buildInputs = [
        (nixpkgs.python3.withPackages (ps:
          with ps; [
            tkinter
            numpy
            pandas
          ]))
        nixpkgs.mambaforge
      ];
    };
  };
}
