{ config, lib, ... }:
{
  programs.nixvim.autoCmd = [
    {
      command = "setlocal shiftwidth=2 softtabstop=2 expandtab";
      event = [ "FileType" ];
      pattern = [ "nix" ];
    }
  ];
}
