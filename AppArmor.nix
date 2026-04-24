{ config, pkgs, lib, ... }: {

  # 1. Habilita o AppArmor no Kernel e no Sistema
  security.apparmor = {
    enable = true;
    packages = with pkgs; [ 
      apparmor-profiles 
    ];
  };

  # CORREÇÃO: Adicionado o ';' e a configuração de ordem do LSM
  security.lsm = [ "landlock" "lockdown" "yama" "integrity" "apparmor" "bpf" ];

  # 2. Integra o AppArmor com o barramento de mensagens do sistema
  services.dbus.apparmor = "enabled";
  security.pam.services.login.enableAppArmor = lib.mkForce false;
  # 3. Automação: Força o AppArmor a carregar antes dos outros serviços
  systemd.services.apparmor.serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = "yes";
  };
}
