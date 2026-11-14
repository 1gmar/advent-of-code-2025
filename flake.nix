{
  description = "Advent of Code 2025";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    aoc-test-runner = {
      url = "github:1gmar/aoc-test-runner";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-1gmar = {
      url = "github:1gmar/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      aoc-test-runner,
      nixvim-1gmar,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      run-tests = aoc-test-runner.packages.${system}.default;
      neovim = nixvim-1gmar.packages.${system}.default.extend {
        languages = {
          nushell.enable = true;
          prolog.enable = true;
        };
      };
      checkCmd = pkgs.writeShellApplication {
        name = "check";
        runtimeInputs = [ pkgs.nix ];
        text = ''
          exec nix build --impure -L --no-link ".#checks.${system}.default"
        '';
      };
      resources = builtins.path {
        name = "resources";
        path = /. + (builtins.getEnv "RESOURCES_DIR");
      };
    in
    {
      checks.${system}.default =
        pkgs.runCommandLocal "run-tests"
          {
            nativeBuildInputs = [
              run-tests
              pkgs.nushell
              pkgs.scryer-prolog
            ];
            NU_LIB_DIRS = aoc-test-runner.modules;
          }
          ''
            set -e
            ln -s ${./src} src
            ln -s ${resources} resources
            run-tests
            touch $out
          '';
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = [
          checkCmd
          run-tests
          neovim
          pkgs.nushell
          pkgs.scryer-prolog
        ];
        shellHook = ''
          export RESOURCES_DIR="$PWD/resources"
          export NU_LIB_DIRS="${aoc-test-runner.modules}:$NU_LIB_DIRS"
        '';
      };
    };
}
