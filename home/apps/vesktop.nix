{ pkgs, ... }:
{
  home.packages = with pkgs; [ vesktop ];
  programs.vesktop = {
    enable = false;
    vencord = {
      settings = {
        autoUpdate = false;
        autoUpdateNotifications = false;
        themeLinks = [ ];
        enabledThemes = [ ];
        plugins = {
          CommandsAPI.enabled = true;
          MessageAccessoriesAPI.enabled = true;
          MessageEventsAPI.enabled = true;
          UserSettingsAPI.enabled = true;
          AnonymiseFileNames.enabled = true;
          BetterGifPicker.enabled = true;
          CrashHandler.enabled = true;
          FakeNitro.enabled = true;
          FavoriteGifSearch.enabled = true;
          FullSearchContext.enabled = true;
          GifPaste.enabled = true;
          IrcColors.enabled = true;
          OpenInApp.enabled = true;
          VolumeBooster.enabled = true;
          WebKeybinds.enabled = true;
          WebScreenShareFixes = {
            enabled = true;
            experimentalAV1Support = false;
          };
          BadgeAPI.enable = true;
          NoTrack = {
            enabled = true;
            disableAnalytics = true;
          };
          Settings = {
            enabled = true;
            settingsLocation = "aboveNitro";
          };
          DisableDeepLinks.enabled = true;
          SupportHelper.enabled = true;
          WebContextMenus.enabled = true;
        };
      };
    };
  };
}
