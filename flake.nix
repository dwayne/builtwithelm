{
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem(system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        buildCss = pkgs.callPackage ./nix/build-css.nix {};
        buildWorkshop = pkgs.callPackage ./nix/build-workshop.nix {};

        css = buildCss {
          name = "builtwithelm-css";
        };

        cssOptimized = buildCss {
          name = "builtwithelm-css-optimized";
          optimize = true;
        };

        workshop = buildWorkshop {
          inherit css;
          name = "builtwithelm-workshop";
        };
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
          inherit css cssOptimized workshop;
        };
      }
    );
}
