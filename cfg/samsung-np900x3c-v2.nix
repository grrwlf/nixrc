# the system.  Help is available in the configuration.nix(5) man page
# or the NixOS manual available on virtual console 8 (Alt+F8).

{ config, pkgs, ... }:

rec {
  require = [
      /etc/nixos/hardware-configuration.nix
      ./include/devenv.nix
      ./include/subpixel.nix
      ./include/haskell.nix
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

  boot.extraKernelParams = [
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

    # interfaceMonitor.enable = false;
    # wireless.enable = false;
    # useDHCP = false;
    #
    # wicd.enable = true;

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
    sudo.configFile =
      ''
        # Don't edit this file. Set nixos option security.sudo.configFile instead
        # env vars to keep for root and %wheel also if not explicitly set
        Defaults:root,%wheel env_keep+=LOCALE_ARCHIVE
        Defaults:root,%wheel env_keep+=NIX_PATH
        Defaults:root,%wheel env_keep+=TERMINFO_DIRS

        # "root" is allowed to do anything.
        root        ALL=(ALL) SETENV: ALL

        # Users in the "wheel" group can do anything.
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

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services.dbus.packages = [ pkgs.gnome.GConf ];

  # Enable the X11 windowing system.
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

  programs = {

    bash = {

      # bashrc {{{
      shellInit = with pkgs ;
        let 
          git = gitAndTools.gitFull;
        in ''
        export EDITOR=${vimHugeX}/bin/vim
        export VERSION_CONTROL=numbered
        export SVN_EDITOR=$EDITOR
        export LANG="ru_RU.UTF-8"
        export OOO_FORCE_DESKTOP=gnome
        export LC_COLLATE=C
        export HISTCONTROL=ignorespace:erasedups
        export PATH="$HOME/.cabal/bin:$PATH"
        export PATH="$HOME/local/bin:$PATH"

        cal()     { `which cal` -m "$@" ; }
        df()      { `which df` -h "$@" ; }
        du()      { `which du` -h "$@" ; }
        man()     { LANG=C ${man}/bin/man "$@" ; }
        feh()     { ${feh}/bin/feh -. "$@" ; }

        q() 		  { exit ; }
        s() 		  { ${screen}/bin/screen ; }
        e() 		  { thunar . 2>/dev/null & }

        log() 		{ ${vimHugeX}/bin/vim /var/log/messages + ; }
        logx() 		{ ${vimHugeX}/bin/vim /var/log/X.0.log + ; }

        cdt() 		{ cd $HOME/tmp ; }
        cdd()     { cd $HOME/dwnl; }
        gitk() 		{ LANG=C ${git}/bin/gitk "$@" & }
        mcd() 		{ mkdir "$1" && cd "$1" ; }
        vimless() { ${vimHugeX}/bin/vim -R "$@" - ; }
        pfind() 	{ ${findutils}/bin/find -iname "*$1*" ; }
        d() 	    { load-env-dev ; }
        manconf() { ${man}/bin/man configuration.nix ; }
        gf()      { ${git}/bin/git fetch github || ${git}/bin/git fetch origin ; }
        beep()    { aplay ~/proj/dotfiles/beep.wav ; }

        # qvim()    { ${qvim}/bin/qvim;
        #             for i in 1 2 ; do ${wmctrl}/bin/wmctrl -r :ACTIVE: -b toggle,maximized_vert,maximized_horz ; done
        #           }
      '';
      # }}}

      promptInit = ''
        PROMPT_COLOR="1;31m"
        let $UID && PROMPT_COLOR="1;32m"
        PS1="\n\[\033[$PROMPT_COLOR\][\u@\h \w ]\\$\[\033[0m\] "
        if test "$TERM" = "xterm"; then
          PS1="\[\033]2;\h:\u: \w\007\ ]$PS1"
        fi
      '';

      enableCompletion = true;
    };

    screen = {

      # screenrc {{{
      screenrc = ''
        vbell off
        msgwait 1
        defutf8 on
        startup_message off
        defscrollback 5000
        altscreen on
        autodetach off
        hardstatus alwayslastline "%{= Kw} %H : %{= Kw}%-w%{= wk}%n %t%{= Kw}%+w"

        multiuser on
        acldel guest
        chacl guest -r-w-x "#?"

        attrcolor b ".I"
        termcapinfo xterm*|rxvt-unicode* 'Co#256:AB=\E[48;5;%dm:AF=\E[38;5;%dm'
        defhstatus "screen ^E (^Et) | $USER@^EH"

        defbce "on"

        deflogin on
        shell -$SHELL

        bind q quit
        bind u copy
        bind s
        bind 0 number 0
        bind 1 number 1
        bind 2 number 2
        bind 3 number 3
        bind 4 number 4
        bind 5 number 5
        bind 6 number 6
        bind 7 number 7
        bind k kill

        bindkey ^[1 prev
        bindkey ^[2 next
        bindkey ^[q prev
        bindkey ^[й prev
        bindkey ^[w next
        bindkey ^[ц next
        bindkey ^[` other
      '';

      # }}}

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
    gxneur
    mplayer
    xlibs.xev
    xfontsel
    xlsfonts
    djvulibre
    ghostscript
    djview4
    tightvnc
    wine
    xfce.xfce4_cpufreq_plugin
    xfce.xfce4_systemload_plugin
    xfce.gigolo
    xfce.xfce4taskmanager
    vlc
    /* easytag */
    /* libreoffice */
    pidgin
    /* gimp_2_8 */
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

