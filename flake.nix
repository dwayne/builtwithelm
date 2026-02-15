{
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem(system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        buildCss = pkgs.callPackage ./nix/build-css.nix {};
      in
      {
        devShells.default = pkgs.mkShell {
          name = "builtwithelm";

          packages = [
          ];

          shellHook = ''
            export PROJECT_ROOT="$PWD"
            export PS1="($name)\n$PS1"
          '';
        };

        packages = {
          css = buildCss {
            name = "builtwithelm-css";
          };

          cssOptimized = buildCss {
            name = "builtwithelm-css-optimized";
            optimize = true;
          };
        };
      }
    );
}
