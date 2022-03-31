# smashgg-social-finder

Get the social media connections for the top 8 players in a bracket.

* https://djanatyn.github.io/smashgg-social-finder/

# Motivation

Quickly creating top 8 graphics! And DevDogg.

# What is a slug?

For a tournament that looks like this:
```
https://smash.gg/tournament/meta-knight-fight-night/event/project-singles/entrant/9184648
```

The slug is this (after `/tournament/` in the URL path):

```
meta-knight-fight-night
```

# How do I get a key?

> In order to access smash.gg’s API, you must use an authentication token. These tokens can be created from the Developer Settings page in your account settings.

Visit https://smash.gg/admin/profile/developer when logged into your smash.gg account.

There's an illustrated tutorial available:
* https://developer.smash.gg/docs/authentication

Unforuntately, there's no support for guest keys available on their public API. The private API does not require a token, but is not available due to CORS restrictions (?).

If you need help getting a key, message `djanatyn`!

# Building

This code is written in Elm.

``` sh
elm make src/Main.elm --optimize --output=elm.js
```

Deploy in the same directory as:
* `index.html`
* `style.css`

# Nix Stuff

I'm using [elm2nix](https://github.com/cachix/elm2nix). There's a `flake.nix`:
```
❯ nix flake show github:djanatyn/smashgg-social-finder
github:djanatyn/smashgg-social-finder/ef206b60ca5965b38c7b534bfdb6c08361395047
└───packages
    └───x86_64-linux
        └───smashgg-social-finder: package 'smashgg-social-finder'
```

You can use `nix develop` to hack on the site, with dependencies set up:
```
❯ nix develop github:djanatyn/smashgg-social-finder#smashgg-social-finder -c elm --version
0.19.1
```

Building the derivation will execute `elm make` and `uglifyjs`:
```
❯ nix eval --raw github:djanatyn/smashgg-social-finder#smashgg-social-finder.installPhase
mkdir -p $out/share/doc

elm make src/Main.elm --output="$out/elm.js"

uglifyjs $out/elm.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' \
  | uglifyjs --mangle --output $out/elm.min.js

install -Dm755 index.html $out/index.html
install -Dm755 style.css $out/style.css
```

You can view the compiled site:
```
❯ ls "$(nix build github:djanatyn/smashgg-social-finder#smashgg-social-finder --no-link --json | jq '.[] | .outputs.out' -r)"
elm.js  elm.min.js  index.html  share  style.css
```

# TODO

* Link to smash.gg profile in output
* Link to social media accounts in output
* Include decoded standing information in output
* Document how to grab a GraphQL Smash.gg API Key on main page
* Deploy
