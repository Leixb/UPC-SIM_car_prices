{
  description = "Manage R + knitr + LaTeX + minted";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        R-packages = with pkgs.rPackages; [
          FSelector
          FactoMineR
          car
          corrplot
          cowplot
          devtools
          factoextra
          ggfortify
          kableExtra
          knitr
          lmtest
          maps
          mice
          papeR
          tidyverse
          xtable
        ];
        R-dev-packages = with pkgs.rPackages; [
          docopt
          git2r
          languageserver
        ];

        R-build = pkgs.rWrapper.override { packages = R-packages; };
        R-devShell = pkgs.rWrapper.override { packages = R-packages ++ R-dev-packages; };

        packages = with pkgs; [
          (texlive.combine {
            inherit (texlive)
              scheme-medium
              framed
              titlesec
              cleveref
              multirow
              wrapfig
              tabu
              threeparttable
              threeparttablex
              makecell
              environ
              biblatex
              biber
              minted
              fvextra
              upquote
              catchfile
              xstring
              ;
          })
          pandoc
          which
          python39Packages.pygments
        ];

        dev-packages = with pkgs; [
          texlab
          zathura
          wmctrl
          pre-commit
        ];

        document-build = { self, name, target ? "pdf_document" }:
          with import nixpkgs { system = "${system}"; };
          stdenv.mkDerivation {
            inherit name;
            src = self;
            buildInputs = [
              R-build
              packages
            ];

            configurePhase = ''
              export TEXMFHOME=$PWD/cache
              export TEXMFVAR=$PWD/cache/var
            '';

            buildPhase = ''
              R -e 'rmarkdown::render("car_prices.Rmd", output_format="${target}", output_dir="build", output_options=list(self_contained=TRUE))'
            '';

            installPhase = ''
              rm -r build/car_prices_files
              mv build "$out"
            '';

          };

      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            R-devShell
            packages
            dev-packages
          ];

          shellHook = ''
            mkdir -p "$(pwd)/_libs"
            export R_LIBS_USER="$(pwd)/_libs"
          '';
        };

        packages = flake-utils.lib.flattenTree {
          pdf = document-build {
            inherit self;
            name = "SIM-document-pdf";
            target = "pdf_document";
          };

          html = document-build {
            inherit self;
            name = "SIM-document-html";
            target = "html_document";
          };

          all = document-build {
            inherit self;
            name = "SIM-document-all";
            target = "all";
          };
        };

        defaultPackage = self.packages.${system}.pdf;
      }
    );

}
