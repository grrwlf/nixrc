{ config, pkgs, ... } :
{
  security = {
    sudo.configFile = ''
      Defaults:root,%wheel env_keep+=NIX_DEV_ROOT
    '';
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

}

