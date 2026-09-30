{ jpegoptim
, optipng
, writeShellApplication
}:

writeShellApplication {
  name = "optimize-images";
  runtimeInputs = [ jpegoptim optipng ];
  text = ''
    src="$1"

    # Optimize JPEG images
    find "$src" \( -iname '*.jpg' -o -iname '*.jpeg' \) -exec jpegoptim --strip-all {} \;

    # Optimize PNG images
    find "$src" -iname '*.png' -exec optipng {} \;
  '';
}
