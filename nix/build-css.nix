{ dart-sass
, runCommand
}:

{ name
, optimize ? false
}:

runCommand name {
  nativeBuildInputs = [ dart-sass ];
  src = ../styles;
} ''
  mkdir "$out"
  ${if optimize then
    ''
    sass --style=compressed --no-source-map "$src/index.scss" "$out/index.css"
    ''
  else
    ''
    sass --embed-sources "$src/index.scss" "$out/index.css"
    ''
  }
''
