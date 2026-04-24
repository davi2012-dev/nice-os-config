{ config, pkgs, ... }: {
  # 1. Habilita o Steam (Essencial para os 2TB de jogos)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Abre portas para o Steam Link
    dedicatedServer.openFirewall = true;
  };

  # 2. Pacotes de Diversão e Lazer
  environment.systemPackages = with pkgs; [
    # Jogos e Emuladores
            # O melhor emulador de PS1 (roda liso no i5)
    pcsx2             # Emulador de PS2
    heroic            # Launcher para Epic Games e GOG (muito foda)
    prismlauncher     # O melhor para Minecraft (modular e rápido)
    ryubing
    retroarch
    retroarch-joypad-autoconfig
    vvvvvv
    supertuxkart
    supertux
    bsdgames
    ataripp
    dosbox
    np2kai
    rpcs3
    vice
    extremetuxracer
    vkquake
    ioquake3
    yquake2
    tuxtype
    tuxpaint
    tuxguitar
    gnome-chess    
    # Visual e Personalização
    cmatrix           # Aquele efeito do Matrix no terminal
    pipes             # Canos animados no terminal
    hollywood
    asciiquarium         
    sl
    cowsay
    fortune
    oneko
    figlet
    espeak
    cava
    xeyes
    xscreensaver
    cool-retro-term
    gnugo
    nyancat
    linux_logo
    links2
    peaclock
    # Social e Lazer          
    stremio-linux-shell   
  ];

  # 3. Gamemode (Melhora a performance do i5 nos jogos)
  programs.gamemode.enable = true;
}
