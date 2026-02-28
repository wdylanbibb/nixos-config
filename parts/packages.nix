{
  inputs,
  lib,
  config,
  ...
}:
let
  wrappers = inputs.wrappers;
  mkWrapper =
    dir: mkValue:
    dir
    |> builtins.readDir
    |> builtins.attrNames
    |> map (file: "${dir}/${file}")
    |> map (mod: rec {
      name = mod |> builtins.baseNameOf |> builtins.unsafeDiscardStringContext |> lib.removeSuffix ".nix";
      value = mkValue { inherit name mod; };
    })
    |> builtins.listToAttrs;
in
{
  imports = [ wrappers.flakeModules.wrappers ];

  perSystem = { ... }: { };

  flake.wrappers = mkWrapper config.deploy.var.wrappedPkgs (
    { mod, ... }: lib.modules.importApply mod inputs
  );
}
