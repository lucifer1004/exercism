{
  description = "A multi-language environment for Exercism";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell.override { 
        # # Swift (Discarded for now)
        # inherit (pkgs.swift) stdenv; 
      } {
        buildInputs = [
          # OcaML
          pkgs.ocaml
          pkgs.ocamlPackages.dune_3
          pkgs.ocamlPackages.findlib
          pkgs.ocamlPackages.lsp
          pkgs.ocamlPackages.ounit2
          pkgs.ocamlPackages.ocamlformat

          # Clojure
          pkgs.clojure
          pkgs.leiningen

          # MIPS
          pkgs.openjdk

          # Zig
          pkgs.zig
          pkgs.zls

          # WASM
          pkgs.nodejs_22

          # # Swift (Discarded for now)
          # pkgs.swift
          # pkgs.swiftPackages.Dispatch
          # pkgs.swiftPackages.Foundation
          # pkgs.swiftPackages.swiftpm
          # pkgs.swiftPackages.sourcekit-lsp
          # pkgs.swiftPackages.xcbuild
          # pkgs.swiftPackages.XCTest

          # Python
          pkgs.python311
          pkgs.python311Packages.pytest
        ];

        shellHook = ''
          echo "Welcome to the development shell!"
        '';
      };
    };
}