{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    elm2nix = {
      url = "github:dwayne/elm2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    deploy = {
      url = "github:dwayne/deploy";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, elm2nix, deploy }:
    flake-utils.lib.eachDefaultSystem(system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (elm2nix.lib.elm2nix pkgs) buildElmApplication;

        buildSass = pkgs.lib.makeOverridable (pkgs.callPackage ./nix/build-sass.nix {});
        sass = buildSass {
          src = ./sass;
        };

        buildWorkshop = pkgs.callPackage ./nix/build-workshop.nix {};
        workshop = buildWorkshop {
          inherit sass;
          html = ./workshop;
          images = pkgs.symlinkJoin {
            name = "images";
            paths = [
              ./public/images
              ./workshop/images
            ];
          };
        };

        optimizeImages = pkgs.callPackage ./nix/optimize-images.nix {};

        generateElmLock = pkgs.writeShellApplication {
          name = "generate-elm-lock";
          runtimeInputs = [ elm2nix.packages.${system}.default ];
          text = ''
            exec elm2nix lock ${./elm.json} ${./review/elm.json}
          '';
        };

        build = pkgs.lib.makeOverridable (pkgs.callPackage ./nix/build.nix { inherit buildElmApplication; });
        dev = build {
          inherit sass;
          name = "dev";
        };
        prod = build {
          name = "prod";
          minifyHtml = true;
          sass = sass.override { optimize = true; };
          jsOptimizeLevel = 2;
          compress = true;
        };

        mkServe = pkgs.callPackage ./nix/mk-serve.nix {};
        serveWorkshop = mkServe {
          name = "serve-workshop";
          root = workshop;
          caddyfile = ./Caddyfile;
          port = 9000;
        };
        serveDev = mkServe {
          name = "serve-dev";
          root = dev;
          caddyfile = ./Caddyfile;
        };
        serveProd = mkServe {
          name = "serve-prod";
          root = dev;
          caddyfile = ./Caddyfile;
          port = 8001;
        };

        deployNetlify = pkgs.writeShellApplication {
          name = "deploy-netlify";
          runtimeInputs = [ deploy.packages.${system}.default ];
          text = ''
            exec deploy "$@" "${prod.override { enableRedirects = true; }}" netlify
          '';
        };

        mkApp = { drv, description }: {
          type = "app";
          program = pkgs.lib.getExe drv;
          meta = { inherit description; };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "builtwithelm";

          packages = [
            elm2nix.packages.${system}.default
            generateElmLock
            optimizeImages
            pkgs.actionlint
            pkgs.elmPackages.elm
            pkgs.elmPackages.elm-format
            pkgs.elmPackages.elm-json
            pkgs.elmPackages.elm-review
            pkgs.jpegoptim
            pkgs.optipng
          ];

          shellHook = ''
            export PS1="($name)\n$PS1"
          '';
        };

        packages = {
          inherit sass workshop dev prod serveWorkshop serveDev serveProd;
        };

        apps = {
          serveWorkshop = mkApp {
            drv = serveWorkshop;
            description = "Serve the workshop";
          };

          serveDev = mkApp {
            drv = serveDev;
            description = "Serve the dev version of the app";
          };

          serveProd = mkApp {
            drv = serveProd;
            description = "Serve the prod version of the app";
          };

          deploy = mkApp {
            drv = deployNetlify;
            description = "Deploy the prod version of the app";
          };
        };

        checks = {
          inherit workshop dev prod;
        };
      }
    );
}
