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

  programs.ghostty = {
    enable = true;
    settings = {
      theme = "catppuccin-macchiato";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;
      window-decoration = false;
      
      # Melhora a performance de renderização
      unfocused-split-opacity = 0.7; 
      
      # Garante que o terminal use a GPU (ajuda com sua RX 550)
      renderer = "gles"; 
      
      # Remove a barra de título para um look minimalista (no Wayland/KDE)
      gtk-adwaita = false;
    };
  }; # <--- Faltava esse ponto e vírgula aqui
} # <--- E faltava essa chave para fechar o arquivo