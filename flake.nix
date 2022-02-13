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
            src = ./src;

            buildInputs = with pkgs.elmPackages; [ elm ];

            buildPhase = ''
              elm make $src/Main.elm --optimize --output=elm.js
              # TODO: minify js (elm.js -> elm.min.js)
            '';

            installPhase = ''
              mkdir -p $out

              install -Dm755 index.html $out/index.html
              install -Dm755 elm.min.js $out/elm.js
            '';
          };
        });
    };
}
