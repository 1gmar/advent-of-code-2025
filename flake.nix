{
  description = "Advent of Code 2025";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixvim-1gmar = {
      url = "github:1gmar/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aoc-test-runner = {
      url = "github:1gmar/aoc-test-runner";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixvim-1gmar.follows = "nixvim-1gmar";
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
        git.enable = true;
        languages = {
          nushell.enable = true;
          prolog.enable = true;
        };
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
            ln -s ${./tests} tests
            ln -s ${resources} resources
            run-tests
            touch $out
          '';
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = [
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
