{
  description = "PHP environment for Exercism";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          php83           # PHP 8.3
          php83Packages.composer  # Dependency manager
        ];

        shellHook = ''
          echo "🐘 PHP environment for Exercism"
          echo "PHP: $(php --version | head -1)"
          echo "Composer: $(composer --version 2>/dev/null | head -1 || echo 'Not found')"
          echo ""
          echo "Run 'just test <project>' to test exercises."
        '';
      };
    };
}
