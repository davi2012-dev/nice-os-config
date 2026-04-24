{ config, pkgs, ... }: {
  # Habilita o servidor gráfico X11/Wayland
  services.xserver.enable = true;

  # Gerenciador de login (SDDM é o padrão do KDE)
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Habilita o Desktop Environment KDE Plasma
  services.desktopManager.plasma6.enable = true;

  # Excluir tranqueiras que vêm no KDE por padrão
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa      # Player de música
    kate       # Editor de texto (você já usa nano/vim)
    khelpcenter
    okular     # Leitor de PDF (se não for usar)
  ];

  # Configuração de Áudio (Pipewire é melhor para o Plasma)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
