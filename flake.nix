{
  inputs = { nixpkgs.url = "nixpkgs"; };

  description = "smash.gg social connection finder, for top 8 graphics";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in {
      packages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          smashgg-social-finder = pkgs.stdenv.mkDerivation {
            name = "smashgg-social-finder";
            version = "0.1.0";
            src = ./.;

            buildInputs = with pkgs.elmPackages; [
              elm
              pkgs.nodePackages.uglify-js
            ];

            buildPhase = pkgs.elmPackages.fetchElmDeps {
              elmPackages = import ./elm-srcs.nix;
              elmVersion = "0.19.1";
              registryDat = ./registry.dat;
            };

            installPhase = ''
              mkdir -p $out/share/doc

              elm make src/Main.elm --output="$out/elm.js" --docs "$out/share/doc/smashgg.json"

              uglifyjs $out/elm.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' \
                | uglifyjs --mangle --output $out/elm.min.js

              install -Dm755 index.html $out/index.html
              install -Dm755 style.css $out/style.css
            '';
          };
        });
    };
}
