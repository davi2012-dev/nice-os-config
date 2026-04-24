{
  description = "Darkflake: NixOS Atômico + Repos Extras + Home Manager";

  inputs = {
    # Base do Sistema (Estável 25.11 - Tecnologia Consolidada)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    
    # Unstable para pacotes bleeding edge (Kernel, drivers novos)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager: Gestão de arquivos de config do usuário davi
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Lanzaboote: Tecnologia de Secure Boot para Linux (Estilo Enterprise/OpenBSD)
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Chaotic-NYX: O "Turbo" do Fedora/Arch no NixOS (Kernels Zen com melhorias extras)
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Gestão declarativa de Flatpaks
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # Compatibilidade Affinity (Design no Linux)
    affinity-nix.url = "github:mrshmllow/affinity-nix";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, chaotic, nix-flatpak, affinity-nix, lanzaboote, ... } @ inputs:
    let
      system = "x86_64-linux";
      
      # Configuração para pacotes estáveis
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      
      # Configuração para pacotes instáveis (Tecnologia mais nova)
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations."Darkflake" = nixpkgs.lib.nixosSystem {
        inherit system;
        # Passa os inputs para os outros arquivos (.nix) reconhecerem o Chaotic e Lanzaboote
        specialArgs = { inherit inputs unstable; };
        
        modules = [
          ./configuration.nix # O coração que a gente tunou antes
          
          # Injeção de Tecnologias de Elite
          chaotic.nixosModules.default # Habilita o cache e kernels do Chaotic
          nix-flatpak.nixosModules.nix-flatpak
          lanzaboote.nixosModules.lanzaboote

          # Integração Total do Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs unstable; };
            home-manager.users.davi = import ./home.nix;
          }

          # Configurações de Ativação Rápida
          {
            services.flatpak.enable = true;
            
            # Dica: Com o Chaotic-NYX, você pode usar kernels ainda mais agressivos
            # boot.kernelPackages = pkgs.linuxPackages_cachyos; # Se quiser o máximo de performance
          }
        ];
      };
    };
}