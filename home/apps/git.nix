{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user.name = "Dylan Bibb";
      user.email = "wdylanbibb@gmail.com";
      url."https://github.com/".insteadOf = [
        "gh:"
        "github:"
      ];
    };
  };
}
