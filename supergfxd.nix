{ config, pkgs, ... }:

{
  services.supergfxd.enable = true;

  environment.systemPackages = with pkgs; [
    supergfxctl
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };
}
