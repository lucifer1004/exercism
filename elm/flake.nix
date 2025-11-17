{
  description = "Elm environment for Exercism";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [
          pkgs.elmPackages.elm
          pkgs.elmPackages.elm-test
          pkgs.elmPackages.elm-format
          pkgs.elmPackages.elm-language-server
        ];
      };
    };
}
