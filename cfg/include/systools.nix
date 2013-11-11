{ config, pkgs, ... } :
{

  environment.systemPackages = with pkgs ; [
    psmisc
    iptables
    tcpdump
    pmutils
    file
    cpufrequtils
    zip
    unzip
    unrar
    p7zip
    openssl
    cacert
    w3m
    wget
    screen
    fuse
    mpg321
    catdoc
    tftp_hpa
    atool
    ppp
    pptp
    dos2unix
    fuse_exfat
    acpid
    upower
    smartmontools
    nix-dev

    mc
    gitAndTools.gitFull
    ctags
    subversion
  ];

}
