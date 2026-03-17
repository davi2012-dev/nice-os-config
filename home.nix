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
        email = "seu-email@exemplo.com"; 
        name = "davi miguel";
      };
    };
  };

  programs.zsh.enable = true;
}