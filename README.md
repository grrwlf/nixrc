NixOS Configurations
====================
This folder contains configuration files for my [NixOS](http://www.nixos.org) systems as well as 
nixrc script containing some usefull functions for NixOS development.

* nixos-homeserver.nix
* nixos-intel-ideapad.nix
* nixos-samsung-np900x3c.nix

Nix-Dev
=======

Nixrc is a plain bash script carefully written to assist in NixOS development.

Installing
----------

'Installation' means fetching Nixos/Nixpkgs trees and applying my local
development branch on top of them. ./install does this automatically. It may be
easily customized to use other development trees, but the name of development
branch is mandatory: it should be called 'local'.

Tools
-----
    
    $ nix-dev-
    nix-dev-asroot           nix-dev-pfetch           nix-dev-rebuild-dryrun
    nix-dev-attr-by-name     nix-dev-pfetch-by-attr   nix-dev-rebuild-switch
    nix-dev-fetch            nix-dev-rebase           nix-dev-revision
    nix-dev-follow           nix-dev-rebase-check     nix-dev-revision-latest
    nix-dev-patch            nix-dev-rebuild          nix-dev-unpack
    nix-dev-penv             nix-dev-rebuild-build    nix-dev-update


nix-dev-penv
------------
Usage:

    nix-dev-penv -A ATTR
    nix-dev-penv PACKAGE

Sets up package build environment in a new shell. nix-dev-patch can be used from that shell to generate
a patch showing the difference between original sources and modified ones.

nix-dev-revision-latest
-----------------------
Example:

    $ nix-dev-revision-latest 
    usage: nix-dev-revision-latest nixos|nixpkgs
    revision string: 1def5ba-48a4e91

    $ nix-dev-revision-latest  nixpkgs
    48a4e91

Shows latest stable commit, i.e. commit wich has a Hydra build associated.

nix-dev-update
--------------
Fetches upstream treas and rebases local development branch. The algorithm is
following:
* Updates local nixos and nixpkgs trees from the origin/master
* Determines right commits in both repos to base upon
* Rebases local branches in both repos upon new bases

nix-dev-penv
------------
Sets up build environment for a package in a sub-shell

