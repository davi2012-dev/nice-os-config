{ config, pkgs, ... }:

{
  # O Home Manager precisa saber que versão está usando
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  # Pacotes que só você, davi, quer usar (limpe do seu configuration.nix se quiser)
  home.packages = with pkgs; [
    htop
    fastfetch
    yazi
  ];

  # Configuração do Git integrada
  programs.git = {
    enable = true;
    userName = "davi2012-dev";
    userEmail = "200~DaviMigue@proton.me";
  };

  # Configuração de programas (ex: zsh, git, etc) ficam aqui!
  programs.zsh.enable = true;
}
