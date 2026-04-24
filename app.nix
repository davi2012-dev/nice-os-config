{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Internet e Comunicação
    floorp-bin         
    vesktop            # Para trocar ideia
    telegram-desktop
    
    # Multimídia e Design
    mpv                # O canivete suíço dos vídeos
    gimp               # Para editar suas imagens
    inkscape
    krita

    
    # Ferramentas de Sistema e Terminal
    fastfetch          # Versão moderna e rápida do neofetch
    btop               # Monitor de recursos bonitão para ver os 4 cores do i5
    git                # Essencial para qualquer dev/admin
    vscode             # Editor de código
    ptyxis
    kitty
    lazygit
    television
    fzf
    nushell
    nushellPlugins.formats
    nushellPlugins.query
    nushellPlugins.gstat
    carapace
    starship
    outils
    stress-ng
    nicstat
    eza
    yazi
    gping
    genact
    duf
    ncdu
    zoxide
    appimage-run
    doas-sudo-shim
    distrobox
    distrobox-tui
    topgrade
    # Utilitários
    flameshot          # Para prints de tela 
    warehouse  
    mission-center
    bazaar
    dippi
    localsend
    bottles
    obsidian    
    plan9port
    gearlever
    pidgin
    crow-translate
    distroshelf
  
   libreoffice-fresh
   zathura
   transmission_4-gtk
   unrar
   zip
   p7zip
   rclone

    
];

  # Habilita o suporte a Flatpak (caso algum app só tenha lá)
  services.flatpak.enable = true;
}
