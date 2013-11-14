# the system.  Help is available in the configuration.nix(5) man page
# or the NixOS manual available on virtual console 8 (Alt+F8).

{ config, pkgs, ... }:

rec {
  require = [
      /etc/nixos/hardware-configuration.nix
      ./include/devenv.nix
      ./include/subpixel.nix
      ./include/haskell.nix
      ./include/screenrc.nix
      ./include/bashrc.nix
      ./include/systools.nix
      ./include/fonts.nix
      ./include/security.nix
      ./include/postfix_relay.nix
      <nixos/modules/programs/virtualbox.nix>
    ];

  boot.kernelPackages = pkgs.linuxPackages_3_12 // {
    virtualbox = pkgs.linuxPackages_3_12.virtualbox.override {
      enableExtensionPack = true;
    };
  };

  boot.blacklistedKernelModules = [
    "fbcon"
    ];

  boot.kernelParams = [
    # Use better scheduler for SSD drive
    "elevator=noop"
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  boot.kernelModules = [
    "fuse"
  ];

  i18n = {
    defaultLocale = "ru_RU.UTF-8";
  };

  hardware.enableAllFirmware = true;
  hardware.firmware = [ "/root/firmware" ];
  hardware.bluetooth.enable = false;

  # Europe/Moscow
  time.timeZone = "Etc/GMT-4";

  networking = {
    hostName = "greyblade";

    networkmanager.enable = true;
  };

  fileSystems = [
    { mountPoint = "/";
      device = "/dev/disk/by-label/ROOT";
      options = "defaults,relatime,discard";
    }
    { mountPoint = "/home";
      device = "/dev/disk/by-label/HOME";
      options = "defaults,relatime,discard";
    }
  ];

  powerManagement = {
    enable = true;
  };

  services.ntp = {
    enable = true;
    servers = [ "0.pool.ntp.org" "1.pool.ntp.org" "2.pool.ntp.org" ];
  };

  services.openssh = {
    enable = true;
    ports = [22 2222];
    permitRootLogin = "yes";
  };

  services.dbus.packages = [ pkgs.gnome.GConf ];

  services.xserver = {
    enable = true;

    startOpenSSHAgent = true;

    videoDrivers = [ "intel" ];
    
    layout = "us,ru";

    xkbOptions = "grp:alt_space_toggle, ctrl:swapcaps, grp_led:caps";

    desktopManager = {
      xfce.enable = true;
      # kde4.enable = true;
    };

    displayManager = {
      lightdm = {
        enable = true;
      };
      # slim = {
      #   enable = false;
      #   autoLogin = true;
      #   defaultUser = "grwlf";
      # };
      # kdm = {
      #   enable = true;
      # };
    };

    multitouch.enable = false;

    synaptics = {
      enable = true;
      accelFactor = "0.05";
      maxSpeed = "10";
      twoFingerScroll = true;
      additionalOptions = ''
        MatchProduct "ETPS"
        Option "FingerLow"                 "3"
        Option "FingerHigh"                "5"
        Option "FingerPress"               "30"
        Option "MaxTapTime"                "100"
        Option "MaxDoubleTapTime"          "150"
        Option "FastTaps"                  "0"
        Option "VertTwoFingerScroll"       "1"
        Option "HorizTwoFingerScroll"      "1"
        Option "TrackstickSpeed"           "0"
        Option "LTCornerButton"            "3"
        Option "LBCornerButton"            "2"
        Option "CoastingFriction"          "20"
      '';
    };

    serverFlagsSection = ''
      Option "BlankTime" "0"
      Option "StandbyTime" "0"
      Option "SuspendTime" "0"
      Option "OffTime" "0"
    '';
  };

  environment.systemPackages = with pkgs ; [
    # X11 apps
    unclutter
    xorg.xdpyinfo
    xorg.xinput
    rxvt_unicode
    vimHugeX
    (firefoxLocaleWrapper "ru")
    glxinfo
    feh
    xcompmgr
    zathura
    evince
    xneur
    # gxneur
    mplayer
    xlibs.xev
    xfontsel
    xlsfonts
    djvulibre
    # ghostscript
    # djview4
    # tightvnc
    wine
    xfce.xfce4_cpufreq_plugin
    xfce.xfce4_systemload_plugin
    xfce.xfce4_xkb_plugin
    xfce.gigolo
    xfce.xfce4taskmanager
    vlc
    # easytag
    # libreoffice
    pidgin
    # gimp_2_8
    skype
    /* dosbox */
    /* eclipses.eclipse_cpp_42 */
    networkmanagerapplet

    haskell_7_6
    (devenv {
      enableCross = false;
      enableX11 = services.xserver.enable;
    })
    /* freetype_subpixel */
  ];

  nixpkgs.config = {
    chrome.jre = true;
    firefox.jre = true;
  };

}

