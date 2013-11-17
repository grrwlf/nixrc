{ config, pkgs, ... } :
{
  security = {
    sudo.configFile = ''
      Defaults:root,%wheel env_keep+=NIX_DEV_ROOT
    '';
  };

  users.extraUsers =
  let
    hasvb = pkgs.lib.elem config.boot.kernelPackages.virtualbox config.environment.systemPackages;
    hasnm = config.networking.networkmanager.enable;
  in {
    grwlf = {
      uid = 1000;
      group = "users";
      extraGroups = ["wheel"]
        ++ pkgs.lib.optional hasnm "networkmanager"
        ++ pkgs.lib.optional hasvb "vboxusers";
      home = "/home/grwlf";
      isSystemUser = false;
      useDefaultShell = true;
    };

    galtimir = {
      uid = 1001;
      group = "users";
      extraGroups = ["wheel"]
        ++ pkgs.lib.optional hasnm "networkmanager"
        ++ pkgs.lib.optional hasvb "vboxusers";
      home = "/home/galtimir";
    };
  };
}

