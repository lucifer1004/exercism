{
  description = "Dart development environment for Exercism exercises";

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
            dart              # Dart SDK (includes pub, dart format, dart analyze)
          ];

          shellHook = ''
            echo "Dart development environment"
            dart --version
          '';
        };
      });
}
