{ lib, pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [ vim git ];
    enableAllTerminfo = true;
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
}
