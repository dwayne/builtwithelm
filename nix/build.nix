{ brotli
, buildElmApplication
, html-minifier
, lib
, stdenv
, zopfli
}:

{ name
, sass

, minifyHtml ? false
, jsOptimizeLevel ? 0 # 0 | 1 | 2 | 3
, compress ? false
, enableRedirects ? false
}:

let
  fs = lib.fileset;

  js = buildElmApplication {
    name = "${name}-js";
    src = fs.toSource {
      root = ../.;
      fileset = fs.unions [
        ../review
        ../src
        ../elm.json
      ];
    };
    elmLock = ../elm.lock;
    doElmFormat = true;
    elmFormatSourceFiles = [ "review/src" "src" ];
    doElmReview = true;
    output = "app.js";
    outputMin = "app.js";
    enableDebugger = jsOptimizeLevel == 0;
    enableOptimizations = jsOptimizeLevel > 0;
    optimizeLevel =
      if jsOptimizeLevel < 1 then
        1
      else if jsOptimizeLevel > 3 then
        3
      else
        jsOptimizeLevel
      ;
    doMinification = jsOptimizeLevel > 0;
    useTerser = true;
    doCompression = compress;
    doReporting = true;
  };
in
stdenv.mkDerivation {
  inherit name;
  src = fs.toSource {
    root = ../.;
    fileset = fs.unions [
      ../public
    ];
  };

  nativeBuildInputs = builtins.concatLists [
    []
    (lib.optional minifyHtml html-minifier)
    (lib.optionals compress [ brotli zopfli ])
  ];

  buildPhase = ''
    runHook preBuild

    mkdir site

    ${if minifyHtml then
      ''
      html-minifier                         \
        --collapse-boolean-attributes       \
        --collapse-inline-tag-whitespace    \
        --collapse-whitespace               \
        --decode-entities                   \
        --minify-js                         \
        --remove-comments                   \
        --remove-empty-attributes           \
        --remove-redundant-attributes       \
        --remove-script-type-attributes     \
        --remove-style-link-type-attributes \
        --remove-tag-whitespace             \
        --file-ext html                     \
        --input-dir "$src/public"           \
        --output-dir site
      ''
      else
      ''
      cp "$src/public/"*.html site/
      ''
    }

    cp -r "${sass}/." site
    cp -r "$src/public/images" site
    cp -r "$src/public/data" site
    cp -r "${js}/." site
    ${lib.optionalString enableRedirects ''
      cp "$src/public/_redirects" site/
    ''}

    ${lib.optionalString compress ''
      echo "compressing files"

      chmod -R u+w site

      find site \(        \
           -name "*.html" \
        -o -name "*.css"  \
        -o -name "*.json" \
        -o -name "*.svg"  \
      \)                  \
      -exec sh -c '
        echo "brotli: $1"
        brotli -v "$1"

        echo "zopfli: $1"
        zopfli -v "$1"
      ' _ "{}" \;
    ''}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r site/. "$out"

    runHook postInstall
  '';
}
