{ runCommand }:

{ html
, sass
, images
}:

runCommand "build-workshop" {} ''
  mkdir -p "$out"
  cp "${html}/"*.html "$out"
  cp -r ${sass}/. "$out"
  cp -r ${images}/. "$out"
''
