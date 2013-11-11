## FIXME: this file is quite old and not supported

{config, pkgs, ...}:

{
  require = [
    ./include/bashrc.nix
    ./include/screenrc.nix
    ./include/systools.nix
    ./include/security.nix
    ./include/fonts.nix
    /etc/nixos/hardware-configuration.nix
  ];

  boot.blacklistedKernelModules = [
    "pcspkr"
    "wimax"
    "i2400m"
    "i2400m_usb"
    ];

  boot.initrd.kernelModules = [
    "uhci_hcd" "ehci_hcd" "ahci"
  ];

  boot.kernelModules = [
    "acpi-cpufreq" "configs"
  ];

  boot.extraModprobeConfig = ''
    options snd-hda-intel model="ideapad"
  '';

  boot.extraKernelParams = ["nohpet"];

  boot.loader.grub = {
    enable = true;
    version = 2;
    configurationLimit = 10;
    device = "/dev/sda";
  };

  # Europe/Moscow
  time.timeZone = "Etc/GMT-4";

  networking = {
    hostName = "pokemon";
    networkmanager.enable = true;
  };

  fileSystems = [
    { mountPoint = "/";
      device = "/dev/sda7";
    }

    { mountPoint = "/boot";
      device = "/dev/sda2";
    }

    { mountPoint = "/home";
      device = "/dev/sda6";
    }

    { mountPoint = "/mnt/gentoo";
      device = "/dev/sda5";
    }
  ];

  swapDevices = [
    { device = "/dev/sda1"; }
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
      slim = {
        enable = true;
        defaultUser = "ierton";
      };
    };

    videoDrivers = [ "intel" "vesa" ];
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

  users.extraUsers = {
    galtimir = {
      uid = 1001;
      group = "users";
      extraGroups = ["wheel" "networkmanager"];
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
