{ config, pkgs, ... }: {
  # Ativa o suporte a Virtualização (KVM)
  virtualisation.libvirtd.enable = true;
  
  # Interface gráfica para gerenciar as VMs (estilo Virt-Manager)
  programs.virt-manager.enable = true;

  # Pacotes necessários para o "inferno" das VMs
  environment.systemPackages = with pkgs; [
    qemu_kvm
    libvirt
    bridge-utils
    virt-viewer
    spice-vdagent # Para copiar/colar entre host e VM
  ];

  # Adiciona seu usuário ao grupo libvirtd para não precisar de sudo
  users.users.davi.extraGroups = [ "libvirtd" "kvm" ];

  # Se você quer rodar apps de Android (Waydroid), o inferno começa aqui:
   virtualisation.waydroid.enable = true;
}
