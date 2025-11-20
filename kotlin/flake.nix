{
  description = "Kotlin environment for Exercism";

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
          pkgs.jdk21
          pkgs.kotlin
          pkgs.gradle
          pkgs.kotlin-language-server
          pkgs.ktlint
        ];
      };
    };
}
