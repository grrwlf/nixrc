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
      <nixos/modules/programs/virtualbox.nix>
    ];

  boot.kernelPackages = pkgs.linuxPackages_3_12 // {
    virtualbox = pkgs.linuxPackages_3_12.virtualbox.override {
      enableExtensionPack = true;
    };
  };

  hardware.enableAllFirmware = true;
  hardware.firmware = [ "/root/firmware" ];

  hardware.bluetooth.enable = false;

  boot.blacklistedKernelModules = [
    "fbcon"
    ];

  boot.kernelParams = [
    # Use better scheduler for SSD drive
    "elevator=noop"
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  boot.loader.grub.device = "/dev/sda";

  boot.kernelModules = [
    "fuse"
  ];

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

  security = {
    sudo.configFile = ''
      Defaults:root,%wheel env_keep+=LOCALE_ARCHIVE
      Defaults:root,%wheel env_keep+=TERMINFO_DIRS
      Defaults:root,%wheel env_keep+=NIX_DEV_ROOT
      root        ALL=(ALL) SETENV: ALL
      %wheel      ALL=(ALL) SETENV: NOPASSWD: ALL
    '';
  };

  # services.cron = {
  #   systemCronJobs = [
  #     "* * * * * test ls -l / > /tmp/cronout 2>&1"
  #   ];
  # };

  services.ntp = {
    enable = true;
    servers = [ "server.local" "0.pool.ntp.org" "1.pool.ntp.org" "2.pool.ntp.org" ];
  };

  services.openssh = {
    enable = true;
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

  services.postfix = {
    enable = true;
    setSendmail = true;

    # Thanks to http://rs20.mine.nu/w/2011/07/gmail-as-relay-host-in-postfix/
    extraConfig =
      let
        saslpwd = pkgs.callPackage ./include/sasl_passwd.nix {};
      in ''
        relayhost=[smtp.gmail.com]:587
        smtp_use_tls=yes
        smtp_tls_CAfile=/etc/ssl/certs/ca-bundle.crt
        smtp_sasl_auth_enable=yes
        smtp_sasl_password_maps=hash:${saslpwd}/sasl_passwd
        smtp_sasl_security_options=noanonymous
      '';
  };

  fonts = {
    enableFontConfig = true;
    enableFontDir = true;
    enableCoreFonts = true;
    enableGhostscriptFonts = true;
    extraFonts = with pkgs ; [
      liberation_ttf
      ttf_bitstream_vera
      dejavu_fonts
      terminus_font
      bakoma_ttf
      bakoma_ttf
      ubuntu_font_family
      vistafonts
      unifont
      freefont_ttf
    ];
  };

  users.extraUsers = {
    grwlf = {
      uid = 1000;
      group = "users";
      extraGroups = ["wheel" "vboxusers" "networkmanager"];
      home = "/home/grwlf";
      isSystemUser = false;
      useDefaultShell = true;
    };
  };

  environment.systemPackages = with pkgs ; [

    # Basic tools
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
    bashCompletion
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

    # X11 apps
    unclutter
    xorg.xdpyinfo
    xorg.xinput
    gitAndTools.gitFull
    subversion
    ctags
    mc
    rxvt_unicode
    vimHugeX
    firefoxWrapper
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

    # packageOverrides = pkgs: {
    #   stdenv = pkgs.stdenv // {
    #     platform = pkgs.stdenv.platform // {
    #       kernelExtraConfig = ''
    #         MEI y
    #         MEI_ME y
    #       '';
    #     };
    #   }; 
    # };

  };

}

