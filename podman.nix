{ config, pkgs, ... }: {
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Cria um alias 'docker' para o podman
      dockerCompat = true;

      # Necessário para baixar imagens do docker hub, etc.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Ferramentas úteis para gerenciar containers
  environment.systemPackages = with pkgs; [
    podman-compose # Se você usa arquivos docker-compose
    podman-tui     # Interface de terminal para ver os containers
  ];
}
