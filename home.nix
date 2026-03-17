{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    htop
    fastfetch
    yazi
    heroic
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "DaviMigue@proton.me"; 
        name = "davi2012-dev";
      };
    };
  };

  programs.zsh.enable = true;
}