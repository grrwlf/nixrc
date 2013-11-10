{ config, pkgs, ... } :

{

  nixpkgs.config = {

    packageOverrides = pkgs: {

      haskell_7_6 = (pkgs.haskellPackages_ghc763.ghcWithPackagesOld (self: [
        self.haskellPlatform
        self.cabalInstall
      ]));

    };
  };
}

