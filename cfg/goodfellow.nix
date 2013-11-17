## FIXME: this file is quite old and not supported

{config, pkgs, ...}:

{
  require = [
    ./include/bashrc.nix
    ./include/screenrc.nix
    ./include/systools.nix
    ./include/security.nix
    ./include/fonts.nix
    ./include/postfix_relay.nix
    /etc/nixos/hardware-configuration.nix
  ];

  #boot.initrd.kernelModules = [
  #  "uhci_hcd" "ehci_hcd" "ahci"
  #];

  #boot.kernelModules = [
  #  "acpi-cpufreq" "configs"
  #];

  #boot.extraModprobeConfig = ''
  #  options snd-hda-intel model="ideapad"
  #'';

  boot.extraKernelParams = [
    # SSD-friendly
    #"elevator=noop"
  ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    configurationLimit = 10;
    device = "/dev/sda";
  };

  # Europe/Moscow
  time.timeZone = "Etc/GMT-4";

  networking = {
    hostName = "goodfellow";
    #networkmanager.enable = true;
  };

  fileSystems."/" =
    { device = "/dev/disk/by-label/ROOT";
      fsType = "ext4";
    };
  fileSystems."/home" =
    { device = "/dev/disk/by-label/HOME";
      fsType = "ext4";
    };

  swapDevices = [
    { device = "/dev/disk/by-label/SWAP"; }
  ];

  powerManagement = {
    enable = true;
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "ru_RU.UTF-8";
  };

  services.nixosManual.showManual = false;

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  services.openssh.passwordAuthentication = true;
  services.openssh.ports = [ 22 2222 ];

  services.ntp = {
    enable = true;
    servers = [ "0.pool.ntp.org" "1.pool.ntp.org" "2.pool.ntp.org" ];
  };

  services.xserver = {
    enable = true;
    layout = "us,ru";
    xkbOptions = "eurosign:e, grp:alt_space_toggle, ctrl:swapcaps, grp_led:caps, ctrl:nocaps";
    exportConfiguration = true;
    startOpenSSHAgent = true;
    synaptics = {
      enable = true;
      twoFingerScroll = false;
      additionalOptions = ''
        Option "LBCornerButton" "2"
        Option "LTCornerButton" "3"
        '';
    };

    desktopManager.xfce.enable = true;

    displayManager = {
      # slim = {
      #   enable = true;
      #   defaultUser = "ierton";
      # };

      lightdm = {
        enable = true;

        # extraConfig = ''
        #   [XDMCPServer]
        #   enabled=true
        #   port=177
        #   key=1234567
        #   [VNCServer]
        #   enabled=true
        #   command=${pkgs.x11vnc}/bin/x11vnc
        # '';
      };
    };

    videoDrivers = [ "intel" "vesa" ];
  };

  users.extraUsers = {
    galtimir = {
      uid = 1001;
      group = "users";
      extraGroups = ["wheel"];
      home = "/home/galtimir";
    };
  };

  environment.systemPackages = with pkgs ; [
    # X11 apps
    rxvt_unicode
    vimHugeX
    (firefoxLocaleWrapper "ru")
    glxinfo
    feh
    xcompmgr
    zathura
    evince
    xneur
    mplayer
    unclutter
    trayer
    xorg.xdpyinfo
    xlibs.xev
    xfontsel
    xlsfonts
    djvulibre
    ghostscript
    djview4
    skype
    tightvnc
    wine
    vlc
    easytag
    gqview
    gimp_2_8
  ];

  nixpkgs.config = {
    chrome.enableRealPlayer = true;
    chrome.jre = true;
    firefox.enableRealPlayer = true;
    firefox.jre = true;
  };
}

# vim: expandtab : tabstop=2 : autoindent :
