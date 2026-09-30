# CONFIGURATION

.DEFAULT_GOAL := serve-dev
.DELETE_ON_ERROR:


# CONSTANTS

SOURCES := review/src src


# COMMANDS

.PHONY: sass workshop dev prod serve-workshop serve-dev serve-prod deploy format review check optimize-images clean

sass:
	nix build .#sass -L

workshop:
	nix build .#workshop -L

dev: elm.lock
	nix build .#dev -L

prod: elm.lock
	nix build .#prod -L

serve-workshop:
	nix run .#serveWorkshop

serve-dev: elm.lock
	nix run .#serveDev

serve-prod: elm.lock
	nix run .#serveProd

deploy: elm.lock
	nix run .#deploy

format:
	elm-format $(SOURCES) --yes

review:
	elm-review $(SOURCES)

check:
	test -f elm.lock
	elm-format $(SOURCES) --validate
	elm-review $(SOURCES)
	actionlint
	nix flake check -L

optimize-images:
	optimize-images public/data/images

clean:
	rm -rf elm-stuff result


# FILES

elm.lock: elm.json
	generate-elm-lock
