{ dart-sass
, runCommand
}:

{ src
, optimize ? false
}:

let
  command =
    if optimize then
      ''
      sass --style=compressed --no-source-map "$src/index.scss" "$out/index.css"
      ''
    else
      ''
      sass --embed-sources "$src/index.scss" "$out/index.css"
      '';
in
runCommand "build-sass" {
  inherit src;
  buildInputs = [ dart-sass ];
} command
