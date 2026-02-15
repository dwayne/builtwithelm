{ lib, runCommand }:

{ name, css }:

let
  fs = lib.fileset;
in
runCommand name {
  inherit css;
  src = fs.toSource {
    root = ../.;
    fileset = fs.unions [
      ../public/images
      ../workshop
    ];
  };
} ''
  mkdir -p "$out/images"

  cp "$src/workshop/"*.html "$out"
  cp -r "$css/"* "$out"
  cp -r "$src/workshop/images" "$out"
  cp -r "$src/public/images" "$out"
''
