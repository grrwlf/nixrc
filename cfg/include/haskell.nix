{ config, pkgs, ... } :

let

  haskpkgs = self : [
    self.haskellPlatform
    self.cabalInstall
  ];

in {

  nixpkgs.config = {

    packageOverrides = pkgs: {

      haskell_7_6 = (pkgs.haskellPackages_ghc763.ghcWithPackages haskpkgs);

    };
  };
}

