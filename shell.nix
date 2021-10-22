{ pkgs ? import <nixpkgs> {} }:

let
  R-with-packages = pkgs.rWrapper.override {
    packages = with pkgs.rPackages; [
      FSelector
      FactoMineR
      corrplot
      cowplot
      devtools
      factoextra
      maps
      mice
      suncalc
      tidyverse
    ];
  };
  packages = with pkgs; [
      (texlive.combine { inherit (texlive) scheme-medium framed titlesec ; })
      texlab
      zathura
      pandoc
      wmctrl
  ];
in
  pkgs.mkShell {
    buildInputs = [
      R-with-packages
      packages
    ];
    shellHook = ''
    mkdir -p "$(pwd)/_libs"
    export R_LIBS_USER="$(pwd)/_libs"
    '';
  }
