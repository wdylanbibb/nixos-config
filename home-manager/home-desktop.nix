{ config, pkgs, inputs, ... }:
{
  imports = [
    ./home-shared.nix
    ./herbstluftwm.nix
  ];

  xsession.windowManager.herbstluftwm.enable = true;
}
