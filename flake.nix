{
  description = "Advent of Code 2025";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim-1gmar = {
      url = "github:1gmar/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixvim-1gmar,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.neovim = nixvim-1gmar.packages.${system}.default.extend {
        nushell.enable = true;
      };
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = [
          pkgs.nushell
          self.packages.${system}.neovim
        ];
      };
    };
}
