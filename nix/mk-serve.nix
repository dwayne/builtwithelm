{ caddy, writeShellApplication }:

{ name
, root
, caddyfile
, port ? 8000
}:

writeShellApplication {
  inherit name;
  runtimeInputs = [ caddy ];
  runtimeEnv = {
    inherit root port;
  };
  text = ''
    exec caddy run --adapter caddyfile --config "${caddyfile}"
  '';
}
