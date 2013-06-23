Nix-Dev
=======

Nixdev is a plain bash script carefully written to assist in NixOS development.
The script contains useful finctions allowing user to manage his/her local
development branches for both Nixpkgs and Nixos trees. Main features are:

* Script is designed to be sourced from .bashrc or similar, providing alias for
  nix-env command and a set of nix-dev- functinos.
* ./install will clone Nixpkgs/NixOS sources in local subfolders, allowing
  user to keep several different copies of nixdev on a single system.
* Local development branch (named 'local') can be easily rebased onto
  new stable point, every time it appears in channel. See nix-dev-update. Note,
  that it is able to detect tricky cases and abort possibly dangerous
  operations.
* Package sources can easilly be unpacked, see nix-dev-unpack command.
* nix-dev-penv PKG opens build environment for a package named PKG in a subshell
* nix-dev-rebuild is a wrapper for nixos-rebuild.
* Some small commands like cdp (change dir to the nixPkgs), cdn (cd to Nixos),
  manconf (shortcut for man configuration.nix), and some others. See ./nixrc for
  details.

Installing
----------

'Installation' means cloning Nixos/Nixpkgs trees and creating branch named
'local'. To do so, launch

    ./install

script from the project root. It will clone nixos/nixpkgs to a current directory
and create branch named 'local' for the local development. (name 'local' is
hardcoded). Then, it asks you to link ./nixrc into  your .bashrc in order to
make nix-dev- functions available.

Also, I've wrote helper script ./install-grwlf as an aid for myself in setting
up new machines. It fetched my clones from github and sets up local to point to
them.

My configs
----------

cfg/ folder contains configs for several [NixOS](http://www.nixos.org) systems
including some config libraries that I use.

Tools
=====

nix-env
-------
Just an alias for system's nix-env, with -I flag set to point to a development
tree. See ./nixrc for details.

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

Shows latest stable commit, according to nixos channel. Also there are
nix-dev-revision-intree and nix-dev-revision-sys. First one shows revisions of
your 'local' branch. The second one prints system's revision.

nix-dev-update
--------------
Fetches upstream treas and rebases local development branch. The algorithm is
following:
* Updates local nixos and nixpkgs trees from the origin/master
* Determines right commits in both repos to base upon
* Rebases local branches in both repos upon new bases

nix-dev-penv
------------
Usage: nix-dev-penv [-A] PKG

Sets up build environment for a package PKG in a sub-shell. You are free to do

    $ .  $stdenv/setup
    $ configurePhase
    $ buildPhase

and so on to test how does your Nix expression work. -A flag has same meaning as
in nix-env.

nix-dev-patch
-------------
Designed to be called from the subshell opened by nix-dev-penv. It generates the
patch between package's sources and it's original version. Typical usage are

    $ nix-dev-penv xeyes
    $ . $stdenv/setup
    $ set +e  # disable exit on first error
    $ configurePhase
    (an error has occured, fixing it in other terminal)
    $ configurePhase
    (now everything is ok, let's generate a patch)
    $ nix-dev-patch > ~/quick.patch

~/quick.patch will contain your fixes (manual editing may be needed). Review it
and add to your nix-expression.

nix-dev-unpack
--------------
Usage: nix-dev-unpack [-A] PKG

Unpacks package's tarball (.src filed of a derivation) into a subdirectory. -A
flag has same meaning as in nix-env. Atool package is required for this command.


