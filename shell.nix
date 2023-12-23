let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/d8f2c4d846a2e65ad3f5a5e842b672f0b81588a2.tar.gz") {};
in
pkgs.mkShell {
  packages = [
    pkgs.caddy
    pkgs.elmPackages.elm
    pkgs.elmPackages.elm-format
    pkgs.nodejs-18_x
  ];

  shellHook =
    ''
    export project="$PWD"
    export build="$project/.build"
    export PATH="$project/bin:$PATH"

    npm ci --loglevel error >/dev/null
    '';
}
