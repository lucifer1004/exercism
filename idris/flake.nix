{
  description = "Idris 2 development environment for Exercism exercises";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            idris2
            idris2Packages.pack     # Idris2 package manager
          ];

          shellHook = ''
            echo "Idris 2 development environment"
            idris2 --version
          '';
        };
      });
}
