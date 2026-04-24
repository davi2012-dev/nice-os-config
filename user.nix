{ config, pkgs, ... }: {

  # --- 1. Configuração de Usuários ---
  users.users.davi = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "podman" "libvirtd" "gamemode" ];
    hashedPassword = "$6$x5TPIvnIAAaSZwyl$xk/f1pHhLUr9xEr8i2bPKZyfViGAWn8.JUa9BwtsulONCjnr55sirPin0whcZ1/RP3nnJF2t.XtL5Hl0NYEiA1";
  };

  # Novo usuário Guest (sem poderes)
  users.users.guest = {
    isNormalUser = true;
    description = "Usuario Convidado";
    # Ele não está no grupo 'wheel', então não pode usar doas/sudo
    extraGroups = [ ]; 
    # Senha vazia ou definida (recomendo definir uma simples ou deixar sem para bloquear login direto se quiser)
    initialPassword = "guest"; 
  };

  # --- 2. Trancando o Nix (Restrição de Acesso) ---
  nix.settings = {
    # Apenas o root e membros do grupo 'wheel' (você) podem usar comandos nix
    allowed-users = [ "root" "@wheel" ];
    
    # Trusted users podem até substituir binários na store (perigoso, só para você)
    trusted-users = [ "root" "davi" ];
  };

  # --- 3. Segurança do Sistema ---
  security.doas.enable = true;
  security.sudo.enable = false;
  security.doas.extraRules = [{
    users = [ "davi" ];
    keepEnv = true;
    persist = true;
  }];

  security.chromiumSuidSandbox.enable = true;
}